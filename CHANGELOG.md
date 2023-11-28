# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated Microsoft.SqlServer.SqlManagementObjects to 170.18.0.
- Updated System.Management.Automation to 7.2.16 and PowerShell 7.2.16.
- Updated Microsoft.Data.SqlClient to 5.1.1.

### Fixed

- ErrorAction Continue did not executed batches after an SQL error.

## [1.2.1] - 2023-09-05

### Added

- Added StatementTimeout to `Connect-Instance` command.

## [1.2.0] - 2023-08-24

### Changed

- Verbose script execution prints the filepath.

## [1.1.0] - 2022-08-18

### Added

- Default parameter set for `Connect-Instance`.

## [1.0.0] - 2022-08-18

### Added

- Added Get-Table command.
- Added output to all commands.

### Changed

- Updated to net6.0
- Updated from System.Data.SqlClient to Microsoft.Data.SqlClient.
- Updated from PowerShellStandard.Library to System.Management.Automation
- Updated Microsoft.SqlServer.SqlManagementObjects
- Added pipeline input for `Disconnect-Instance`

### Fixed

- ErrorAction parameter works for `Invoke-Command`.

## [0.5.0] - 2021-10-15

### Added

- Added sql command output handler.
- Added support for line commends in scripts.

### Fixed

- Fixed variables with quoted values.

## [0.4.0] - 2021-09-27

### Added

- Added more parameter sets for `Connect-SmoInstance`.

### Fixed

- Fixed connection exception for Azure SQL.

## [0.3.0] - 2021-09-16

### Added

- Added `$(Variable)` and `:setvar Variable Value` support.

## [0.2.0] - 2021-09-15

### Added

- Added `Invoke-SmoCommand` with batch support (`GO` statement).

## [0.1.0] - 2021-09-12

### Added

- Added `Connect-SmoInstance` and `Disconnect-SmoInstance` commands.

<!-- markdownlint-configure-file {"MD024": { "siblings_only": true } } -->
