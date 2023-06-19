ActiveRecord::Schema.define do
  create_table :filers, id: false do |t|
    t.integer :ein, primary_key: true
    t.string :name
    t.string :address_line_1
    t.string :city
    t.string :state, limit: 2
    t.string :zip, limit: 20
  end

  create_table :forms do |t|
    t.integer :filer_ein, foreign_key: true
    t.date :tax_period
    t.datetime :return_ts
  end
  add_foreign_key :forms, :filers, column: :filer_ein, primary_key: "ein"

  create_table :recipients, id: false do |t|
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
end
