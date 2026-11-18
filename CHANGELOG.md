## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
### Misc

[Unreleased]: https://github.com/carwow/rspec_logfmt_formatter/compare/v0.1.0...master

## [0.1.0] - 2026-11

### Added
* `tests.slowest_file` and `tests.slowest_file_ms` fields: the slowest spec file and its duration in milliseconds
* parallel runs prefix every field with the worker from `TEST_ENV_NUMBER` (`tests.<worker>.`), treating an empty value as worker `1`
* parallel runs on CircleCI also include the node from `CIRCLE_NODE_INDEX` (`tests.<node>-<worker>.`)

### Changed
* `rspec_logfmt_formatter_collate` strips the worker and node prefixes and sums `tests.count`, `tests.errors`, `tests.failures`, `tests.retries` and `tests.skipped`, always writing all five
* `rspec_logfmt_formatter_collate` keeps the slowest file across runs along with its duration, and omits both fields when no run reported one

### Fixed
* README release steps referenced a non-existent `version.rb`

[0.1.0]: https://github.com/carwow/rspec_logfmt_formatter/tree/v0.1.0/

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
