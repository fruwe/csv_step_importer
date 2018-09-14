# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added

### Changed

## 2018-08-22 Version 0.9.0
### Added
- Add csv_option headers_mode

```
  headers_mode is a enum with which you can control how headers will be transformed during the file read.

  Note, that this option will be applied, after the csv_option headers is processed.

  The following values are allowed:
    case_sensitive_symbols:
      "A z" becomes :A_z

    case_insensitive_symbols:
      "A z" becomes :a_z

    preserve:
      "A z" will stay "A z"
```

### Changed
- Deprecated csv_option case_sensitive_headers

## 2018-08-22 Version 0.9.1
### Added
- Add csv_option headers_mode

```
  Add following option:
    symbols:
      "A z" becomes :"A z"
```

### Changed

## 2018-08-22 Version 0.9.2
### Added

### Changed
- Change csv_option headers_mode options symbols

```
  Add following option:
    symbols:
      "A z" becomes :"A z"
      " A z " becomes :"A z"
      "A\"z" becomes :"A\"z"
```

## 2018-09-11 Version 0.10.0
### Added
- Added a simple wrapper class for File and Chunk called Loader to use the same interface for importing a plain array of hashes as well as CSV files.

Usage:

```ruby
CSVStepImporter::Loader.new(rows: data, processor_classes: [Author::ImportableModel]).save!
```

See lib/csv_step_importer/chunk.rb for more options

or

```ruby
CSVStepImporter::Loader.new(
  path: 'authors.csv',
  processor_classes: [Author::ImportableModel],
  csv_options: {file_encoding: "UTF-8"}
).save!
```

See lib/csv_step_importer/file.rb for more options

### Changed

- Changed README, especially a note to include smarter_csv 2.0.0.pre1 into your project
- Chunks default for the first row index is now 0

## 2018-09-11 Version 0.11.0
### Added
- Added methods to DAO
  - dao_for(model:, pluralize: false)
    retrieve a dao for a different model using the same CSV row. This is useful e.g. if you use the reflector to get ids of related data
  - link!
    link this dao to a row
  - unlink!
    unlink this dao from the row and replace it with a different dao
- Model allows now to specify a unique composite key `composite_key_columns` to avoid duplicated daos.

  Usage:

  ```ruby
  class Author < ApplicationRecord
    class ImportableModel < CSVStepImporter::Model::ImportableModel
      def composite_key_columns
        [:name]
      end
    end
  end
  ```

  And a CSV which contains the same name twice or more, like this:

  ```csv
  Author,Book
  A1,B1
  A1,B2
  A2,B3
  ```

  If you do NOT specify `composite_key_columns` you will get three DAOs for A1, A1 and A2.
  If you specify `composite_key_columns` non unique daos will be removed and you only will get A1 and A2.

- The `Model`'s `cache_key` method allows now a `pluralize` option.
- The `Model`'s `cache_key` method is now available in the instance as well.

### Changed

- ImportableModel's finder_keys method now defaults to composite_key_columns
- ImportableModel's Importer (uses ActiveRecord::Import) now raises an exception if the import fails

## 2018-09-12 Version 0.11.1
### Added
### Changed
- Fixed `composite_key_columns` filter functionality

## 2018-09-13 Version 0.11.2
### Added
### Changed
- Revert "ImportableModel's Importer (uses ActiveRecord::Import) now raises an exception if the import fails"
  Since import! runs validations on the model, I reverted import! to import (validations should be performed inside csv_step_importers logic)

## 2018-09-14 Version 0.12.0
### Added
- Added a `set` method to Base, in order to make settings shorter
  Usage:
  ```ruby
    class X < Node
      set :config_a, true
      set :config_b, -> { row.some_array.first }
    end
  ```
- Added dao_for to Row
### Changed
- Changed settings to use the new set method
- dao_for's interface changed
  Before: `dao_for(model: some_model_class_or_instance, pluralize: optional_boolean)`
  After: `dao_for(some_model_class_or_instance, pluralize: optional_boolean)`
