## [Unreleased]

### Added
* `tests.slowest_file`, `tests.slowest_file_ms` and `tests.slow_files` fields
* `RSPEC_LOGFMT_SLOW_FILE_THRESHOLD_MS` to configure the slow file threshold

### Changed
* `rspec_logfmt_formatter_collate` takes the maximum of `tests.slowest_file_ms` (and its file) instead of summing

### Deprecated
### Removed
### Fixed
* README release steps referenced a non-existent `version.rb`

### Security
### Misc

[Unreleased]: https://github.com/carwow/rspec_logfmt_formatter/compare/v0.0.2...master

## [0.0.2] - 2025-07

### Added
* executable `rspec_logfmt_formatter_collate`

### Changed
* formatter to `RspecLogfmtFormatter`

### Removed
* class `RspecLogfmtFormatter::Formatter`

[0.0.2]: https://github.com/carwow/rspec_logfmt_formatter/tree/v0.0.2/

## [0.0.1] - 2021-01
* Initial release

[0.0.1]: https://github.com/carwow/rspec_logfmt_formatter/tree/v0.0.1/
