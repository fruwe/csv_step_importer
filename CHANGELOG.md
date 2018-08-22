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

    symbols:
      "A z" becomes :"A z"

    preserve:
      "A z" will stay "A z"
```

### Changed
- Deprecated csv_option case_sensitive_headers
