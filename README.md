# csv_step_importer

A library to validate, speed up and organize bulk insertion of complex CSV data, including multi-table data.

It depends on

- [zdennis/activerecord-import](https://github.com/zdennis/activerecord-import)
- [GitHub - tilo/smarter_csv](https://github.com/tilo/smarter_csv)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csv_step_importer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv_step_importer

## Usage

### Hello world

Create a new rails application:

```shell
rails new currency_wiki --database=mysql
cd currency_wiki
echo "gem 'csv_step_importer'" >> Gemfile
bundle install
rails g model currency code:string:uniq name:string
rails db:create db:migrate
```

Then edit the model like this:

/app/models/currency.rb

```ruby
class Currency < ApplicationRecord
  class ImportableModel < CSVStepImporter::Model::ImportableModel
    # The model to be updated
    def model_class
      ::Currency
    end

    def columns
      [:code, :name, :created_at, :updated_at]
    end

    def on_duplicate_key_update
      [:name, :updated_at]
    end
  end
end
```


Create a test CSV file and upload it

```shell
rails c
```

```ruby
File.open("currencies.csv", "w") do |file|
  file.write(<<~CSV)
    Name,Code
    Euro,EUR
    United States dollar,USD
    Japanese Yen,JPY
  CSV
end

CSVStepImporter::File.new(path: 'currencies.csv', processor_classes: [Currency::ImportableModel]).save

puts Currency.all.to_yaml
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
