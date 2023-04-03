# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require_relative "../app/helpers/parse_irs_xml.rb"
require "pg"

# Connect to the Postgres database.
conn = PG.connect(dbname: "instrumentl_development")

# Initialize the three related tables we need.

# Create a `filers` table if it doesn't exist.
conn.exec(
  "CREATE TABLE IF NOT EXISTS filers (ein int PRIMARY KEY, name VARCHAR, address_line_1 VARCHAR, city VARCHAR(100), state VARCHAR(2), zip VARCHAR(20))"
)
# Create a `forms` table if it doesn't exist.
conn.exec(
  "CREATE TABLE IF NOT EXISTS forms (id SERIAL PRIMARY KEY, filer_ein INTEGER REFERENCES filers(ein), tax_period DATE, return_ts timestamp with time zone)"
)
# Create a `recipients` table if it doesn't exist.
conn.exec(
  "CREATE TABLE IF NOT EXISTS recipients (ein int, form_id INTEGER REFERENCES forms(id), name VARCHAR, address_line_1 VARCHAR, city VARCHAR(100), state VARCHAR(2), zip VARCHAR(20), cash_grant NUMERIC, purpose VARCHAR)"
)

[1, 2, 3, 4, 5, 6, 7, 8].each do |i|
  return_ts, tax_period, filer_info, recipients_info =
    parse_irs_xml("test/fixtures/irs#{i}.xml")

  puts "test/fixtures/irs#{i}.xml - Processing..."

  ein, name, address_line_1, city, state, zip = filer_info

  # Establish a connection to the database.
  conn = PG.connect(dbname: "instrumentl_development")

  # Unconditionally insert this filer into the filers table,
  # doing nothing if we already have a record of this filer.
  conn.exec_params(
    "INSERT INTO filers (ein, name, address_line_1, city, state, zip) VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT DO NOTHING",
    [ein, name, address_line_1, city, state, zip]
  )

  # Check if this form is brand new.
  # We skip ahead after insertion if it is.
  result =
    conn.exec_params(
      "SELECT * FROM forms WHERE filer_ein = $1 AND tax_period = $2",
      [ein, tax_period]
    )
  thisEntryIsBrandNew = result.ntuples == 0
  if thisEntryIsBrandNew
    # Atomically insert into the table.
    begin
      conn.transaction do
        # Insert a new row for this form.
        conn.exec_params(
          "INSERT INTO forms (filer_ein, tax_period, return_ts) VALUES ($1, $2, $3)",
          [ein, tax_period, return_ts]
        )

        # Insert the corresponding recipients.
        for recipient in recipients_info
          ein, name, address_line_1, city, state, zip, cash_amount, purpose =
            recipient
          conn.exec_params(
            "INSERT INTO recipients (ein, form_id, name, address_line_1, city, state, zip, cash_grant, purpose) VALUES ($1, currval(pg_get_serial_sequence('forms', 'id')), $2, $3, $4, $5, $6, $7, $8)",
            [ein, name, address_line_1, city, state, zip, cash_amount, purpose]
          )
        end
        puts "test/fixtures/irs#{i}.xml - Finished!\n\n"
      end
    rescue PG::Error => e
      puts e.message
    ensure
      conn.close if conn
      # Skip ahead.
      next
    end
  else
    print "Filer with EIN ", ein, " and tax period ", tax_period
    print " already exists; checking for outdated forms...\n"
  end

  outdated_forms =
    conn.exec_params(
      "SELECT * FROM forms WHERE filer_ein = $1 AND tax_period = $2 AND return_ts < $3",
      [ein, tax_period, return_ts]
    )

  thereAreOutdatedForms = outdated_forms.ntuples > 0
  if thereAreOutdatedForms
    begin
      conn.transaction do
        # Atomically delete all corresponding recipients and the outdated form.
        for outdated_form in outdated_forms
          form_id_to_delete = outdated_form["id"]
          puts outdated_form

          print "Deleting all recipients with form id ",
                form_id_to_delete,
                "...\n"
          conn.exec_params(
            "DELETE FROM recipient WHERE form_id = $1",
            [form_id_to_delete]
          )

          print "Deleting form with id ", form_id_to_delete, "...\n"
          conn.exec_params(
            "DELETE FROM form WHERE id = $1",
            [form_id_to_delete]
          )
        end

        # Now, add the new form and the associated recipients.
        conn.exec_params(
          "INSERT INTO forms (filer_ein, tax_period, return_ts) VALUES ($1, $2, $3)",
          [ein, tax_period, return_ts]
        )
        for recipient in recipients_info
          ein, name, address_line_1, city, state, zip, cash_amount, purpose =
            recipient
          conn.exec_params(
            "INSERT INTO recipients (ein, form_id, name, address_line_1, city, state, zip, cash_grant, purpose) VALUES ($1, currval(pg_get_serial_sequence('forms', 'id')), $2, $3, $4, $5, $6, $7, $8)",
            [ein, name, address_line_1, city, state, zip, cash_amount, purpose]
          )
        end
      end
    rescue PG::Error => e
      puts e.message
    ensure
      conn.close if conn
    end
  else
    puts "No outdated forms for filer with EIN " + ein + ","
    print "tax period ", tax_period, ", and return timestamp "
    print return_ts, ".\n\n"
  end
end
