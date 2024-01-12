# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Use unbundled environment for child processes to support nested bundler invokations by @tylerhunt (#10)

### Fixed

- Fix adding a process after the group has been started by @tylerhunt (#11)

## [1.2.1] - 2024-01-11

### Fixed

- Remove dependency on ActiveSupport by @tylerhunt (#9)
- Ruby 3.2

## [1.2.0] - 2022-06-03

### Added

- `run!` and `wait!` to raise error if any process exits with an error code != 0

## [1.1.1] - 2020-12-21

### Fixed

- Replaced deprecated `#with_clean_env` method

## [1.1.0] - 2020-11-19

### Added

- Add support for IPv6 by using the hostname instead of the loopback IPv4 address (#2)

## 1.0.0 - 2019-05-13

### Fixed

- Possible concurrent hash modification while iterating (#1)

[Unreleased]: https://github.com/jgraichen/multi_process/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/jgraichen/multi_process/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/jgraichen/multi_process/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/jgraichen/multi_process/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/jgraichen/multi_process/compare/v1.0.0...v1.1.0
