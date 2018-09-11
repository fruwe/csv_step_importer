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
