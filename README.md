# README

- Ruby version
  `ruby "3.1.0"` (see `Gemfile`)

- System dependencies
  Make sure you have `node` and `npm`, or `nvm`.

- Configuration

- Database creation

- Database initialization

```sh
bin/rails db:seed
```

should acccomplish this locally.

```sh
heroku run rails db:seed
```

should let you seed the production database.

- How to run the test suite
  `bin/rails test test/helpers/parse_irs_xml_test.rb`

- Services (job queues, cache servers, search engines, etc.)
  If `sudo service postgresql status` says `postgresql` is down, you can start it with `sudo service postgresql start`.
  `./bin/dev` run at this repository's root should start the development server.

Feel free to run `sudo service postgresql status` again to make sure it started.

- Deployment instructions

# API

Pagination shows up to 100 results at a time.

To see the first page, no `page` parameter is necessary.

But, you'll need to do http://localhost:3000/api/v1/recipients?page=2 to see the second page of the results from http://localhost:3000/api/v1/recipients, for example.

## Filers

http://localhost:3000/api/v1/filers lets you see filers, and http://localhost:3000/api/v1/filers?ein=472387053, for example, lets you see the unique filer with EIN `472387053`.

## Forms

http://localhost:3000/api/v1/forms lets you see forms, and http://localhost:3000/api/v1/forms?filer_ein=200253310 lets you see forms filed by the filer with EIN `200253310`.

## Recipients

While http://localhost:3000/api/v1/recipients lets you see recipients, http://localhost:3000/api/v1/recipients?form_id=5 shows you `recipients` associated with `form_id` 5.
