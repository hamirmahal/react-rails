require_relative "../app/helpers/parse_irs_xml.rb"

# Initialize the tables
ActiveRecord::Schema.define do
  create_table :filers, id: false, if_not_exists: true do |t|
    t.integer :ein, primary_key: true
    t.string :name
    t.string :address_line_1
    t.string :city
    t.string :state, limit: 2
    t.string :zip, limit: 20
  end

  if ActiveRecord::Base.connection.table_exists?('forms') == false
    create_table :forms, if_not_exists: true do |t|
      t.integer :filer_ein, foreign_key: true
      t.date :tax_period
      t.datetime :return_ts
    end
    add_foreign_key :forms, :filers, column: :filer_ein, primary_key: "ein"
  else
    puts "Table already exists; skipping ahead - forms"
  end

  if ActiveRecord::Base.connection.table_exists?('recipients') == false
    create_table :recipients, id: false, if_not_exists: true do |t|
      t.integer :ein
      t.integer :form_id, foreign_key: true
      t.string :name
      t.string :address_line_1
      t.string :city
      t.string :state, limit: 2
      t.string :zip, limit: 20
      t.decimal :cash_grant
      t.string :purpose
    end
    add_foreign_key :recipients, :forms, column: :form_id, primary_key: "id"
  else
    puts "Table already exists; skipping ahead - recipients"
  end
end

puts "\n"

[1, 2, 3, 4, 5, 6, 7, 8].each do |i|
  return_ts, tax_period, filer_info, recipients_info =
    parse_irs_xml("test/fixtures/irs#{i}.xml")

  puts "test/fixtures/irs#{i}.xml - Processing..."

  ein, name, address_line_1, city, state, zip = filer_info

  # Unconditionally insert a filer into the table if it's new.
  # It's okay if this isn't part of the atomic transaction;
  # the database won't be in an invalid state if we have a new filer
  # without a form filled by the filer.
  filer = Filer.find_or_create_by(
    ein: ein,
    name: name,
    address_line_1: address_line_1,
    city: city,
    state: state,
    zip: zip
  )

  # Process form data atomically to prevent the
  # database from entering an invalid state.
  ActiveRecord::Base.transaction do
    # If this form is for a unique tax period...
    if Form.exists?(filer_ein: ein, tax_period: tax_period) == false
      # Create a new form associated with this filer.
      form = Form.create!(
        filer_ein: ein,
        tax_period: tax_period,
        return_ts: return_ts
      )

      # Add the associated recipients.
      recipients_info.each do |recipient|
        ein, name, address_line_1, city, state, zip, cash_amount, purpose = recipient
        form.recipients.create!(ein: ein, name: name, address_line_1: address_line_1, city: city, state: state, zip: zip, cash_grant: cash_amount, purpose: purpose)
      end

      # Continue onto the next file.
      next
    else
      print "Filer with EIN ", ein, " and tax period ", tax_period
      print " already exists; checking for outdated forms...\n"
    end

    thereWasAtLeast1OutdatedForm = false;
    Form.where(tax_period: tax_period).where(filer_ein: ein).where('return_ts < ?', return_ts).each do |form|
      thereWasAtLeast1OutdatedForm = true;
      # Delete all recipients associated with this form.
      form.recipients.destroy_all
      # Delete this form.
      form.destroy
    end

    if thereWasAtLeast1OutdatedForm
      # Add the new form and the associated recipients.
      form = Form.create!(filer_ein: ein, tax_period: tax_period, return_ts: return_ts)

      recipients_info.each do |recipient|
        ein, name, address_line_1, city, state, zip, cash_amount, purpose = recipient
        form.recipients.create!(ein: ein, name: name, address_line_1: address_line_1, city: city, state: state, zip: zip, cash_grant: cash_amount, purpose: purpose)
      end
    end
  end

  puts "test/fixtures/irs#{i}.xml - Finished!\n\n"
end
