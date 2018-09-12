# csv_step_importer

A library to validate, speed up and organize bulk insertion of complex CSV data into multiple tables.

It depends on

- [zdennis/activerecord-import](https://github.com/zdennis/activerecord-import)
- [GitHub - tilo/smarter_csv](https://github.com/tilo/smarter_csv)

## Installation

Add this line to your application's Gemfile:

```ruby
# Quicker CSV processing
gem 'csv_step_importer'
gem 'smarter_csv', github: 'tilo/smarter_csv'
```

NOTE: you might need to add `gem 'smarter_csv', github: 'tilo/smarter_csv'` if you encounter problems building rows

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv_step_importer

## Usage

### Hello world setup (super simple sample, single table, no user-defined row, no user-defined dao)

First let's create a basic rails application to play around with

```shell
rails new bookshop --database=mysql
cd bookshop
echo "gem 'csv_step_importer'
gem 'smarter_csv', github: 'tilo/smarter_csv'" >> Gemfile
bundle install
rails g model author name:string:uniq email:string
rails g model book author:references name:string:uniq
rails db:create db:migrate
```

Then edit the model like this:

app/models/author.rb

```ruby
class Author < ApplicationRecord
  class ImportableModel < CSVStepImporter::Model::ImportableModel
    # The model to be updated
    def model_class
      Module.nesting[1]
    end

    # return CSVStepImporter::Model::Reflector in order to enable reflections (e.g. get ids of all rows)
    # disabled by default
    def reflector_class
      CSVStepImporter::Model::Reflector
    end

    def columns
      [:name, :email, :created_at, :updated_at]
    end

    def composite_key_columns
      [:name]
    end

    def on_duplicate_key_update
      [:email, :updated_at]
    end
  end
end
```

### Simple upload of a single row

```shell
rails c
```

```ruby
irb(main)> data = [{ name: 'Milan Kundera', email: 'milan.kundera@example.com' }]
irb(main)> importer = CSVStepImporter::Loader.new(rows: data, processor_classes: [Author::ImportableModel])
irb(main)> importer.valid?
=> true
irb(main)> importer.save!
   (1.1ms)  SET NAMES utf8,  @@SESSION.sql_mode = CONCAT(CONCAT(@@sql_mode, ',STRICT_ALL_TABLES'), ',NO_AUTO_VALUE_ON_ZERO'),  @@SESSION.sql_auto_is_null = 0, @@SESSION.wait_timeout = 2147483
   (0.4ms)  BEGIN
  [Author::ImportableModel, Author(id: integer, name: string, email: string, created_at: datetime, updated_at: datetime)]
   (13.3ms)  SHOW VARIABLES like 'max_allowed_packet';
  Author Create Many Without Validations Or Callbacks (9.2ms)  INSERT INTO `authors` (`name`,`email`,`created_at`,`updated_at`) VALUES ('Milan Kundera','milan.kundera@example.com','2018-09-11 11:33:07','2018-09-11 11:33:07') ON DUPLICATE KEY UPDATE `authors`.`email`=VALUES(`email`),`authors`.`updated_at`=VALUES(`updated_at`)
   (154.6ms)  COMMIT
  => true

irb(main)> puts JSON.parse(Author.all.to_json).to_yaml # Isn't there an easy way to get clean yaml...

   ---
   - id: 7
     name: Milan Kundera
     email: milan.kundera@example.com
     created_at: '2018-09-11T11:42:15.000Z'
     updated_at: '2018-09-11T11:42:15.000Z'

irb(main)> data = [{ name: 'Milan Kundera', email: 'milan.kundera2@example.com' }, { name: 'Immanuel Kant', email: 'immanuel.kant@example.com' }]
irb(main)> CSVStepImporter::Loader.new(rows: data, processor_classes: [Author::ImportableModel]).save!
=> true
irb(main)> puts JSON.parse(Author.all.to_json).to_yaml # Isn't there an easy way to get clean yaml...

# NOTE: updated_at changed, but the id did not
---
- id: 7
  name: Milan Kundera
  email: milan.kundera2@example.com
  created_at: '2018-09-11T11:42:15.000Z'
  updated_at: '2018-09-11T12:19:17.000Z'
- id: 9
  name: Immanuel Kant
  email: immanuel.kant@example.com
  created_at: '2018-09-11T12:19:17.000Z'
  updated_at: '2018-09-11T12:19:17.000Z'
```

### File import using [tilo/smarter_csv](https://github.com/tilo/smarter_csv)

```shell
rails c
```

```ruby
irb(main)> File.open("authors.csv", "w") do |file|
  file.write(<<~CSV)
    Name,Email
    Milan Kundera,milan.kundera@example.com
    Immanuel Kant,immanuel.kant@example.com
  CSV
end

irb(main)> CSVStepImporter::Loader.new(path: 'authors.csv', processor_classes: [Author::ImportableModel], csv_options: {file_encoding: "UTF-8"}).save
=> true

irb(main)> puts JSON.parse(Author.all.to_json).to_yaml

# NOTE: The email and updated_at is updated as specified in on_duplicate_key_update
---
- id: 7
  name: Milan Kundera
  email: milan.kundera@example.com
  created_at: '2018-09-11T11:42:15.000Z'
  updated_at: '2018-09-11T12:24:13.000Z'
- id: 9
  name: Immanuel Kant
  email: immanuel.kant@example.com
  created_at: '2018-09-11T12:19:17.000Z'
  updated_at: '2018-09-11T12:24:13.000Z'
```

### Simple model

By default, for each row read from the CSV file, a DAO belonging to a model will be created.
These models will be validated and saved in the order specified by the processor_classes option.

The simplest model is one, which simply calls `save` on all DAOs, which calls internally `create_or_update`.
`create_or_update` is customizable.

Example:

This example will call `find_or_create_by` for each row after all validations have passed.

```ruby
class SimpleDAO < CSVStepImporter::Model::DAO
  def create_or_update
    Currency.find_or_create_by( name: row.name, code: row.code )
  end
end

class SimpleModel < CSVStepImporter::Model::Model
  def dao_class
    SimpleDAO
  end
end

CSVStepImporter::Loader.new(path: 'currencies.csv', processor_classes: [SimpleModel]).save
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fruwe/csv_step_importer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CSVStepImporter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fruwe/csv_step_importer/blob/master/CODE_OF_CONDUCT.md).
