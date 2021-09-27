# PsSmo

The PowerShell SQL Client module replaces the SQL Server utilities [SQLCMD](https://docs.microsoft.com/de-de/sql/tools/sqlcmd-utility) with native PowerShell commands.

## Installation

This module can be installed from [PsGallery](https://www.powershellgallery.com/packages/PsSmo).

```powershell
Install-Module -Name PsSmo -Scope CurrentUser
```

Alternatively it can be build and installed from source.

1. Install the development dependencies
2. Download or clone it from GitHub
3. Run the installation task:

```powershell
Invoke-Build Install
```

## Usage

TODO

Execute SQLCMD scripts like those created by [DacFX](https://github.com/microsoft/DacFx).

### Commands

| Command                         | Description                             | Status  |
| ------------------------------- | --------------------------------------- | ------- |
| Connect-Instance                | Create a new database connection.       | &#9745; |
| Disconnect-Instance             | Close connection                        | &#9745; |
| Invoke-Command                  | Execute SQLCMD scripts                  | &#9744; |
| &#11185; Batch support          | Support `GO` statements                 | &#9745; |
| &#11185; File support           | Script source from file                 | &#9745; |
| &#11185; Variable support       | Support variables like `$(variable)`    | &#9745; |
| &#11185; :setvar support        | Support `:setvar`                       | &#9745; |
| &#11185; SQLCMD command support | Support SQLCMD commans like `:on error` | &#9744; |

## Changelog

### 0.1.0

- Added `Connect-SmoInstance` and `Disconnect-SmoInstance` commands.

### 0.2.0

- Added `Invoke-SmoCommand` with batch support (`GO` statement).

### 0.3.0

- Added `$(Variable)` and `:setvar Variable Value`  support.

### 0.4.0

- Added more parameter sets for `Connect-SmoInstance`.
- Fixed connection exception for Azure SQL.

## Development

- This is a [Portable Module](https://docs.microsoft.com/de-de/powershell/scripting/dev-cross-plat/writing-portable-modules?view=powershell-7) based on [PowerShell Standard](https://github.com/powershell/powershellstandard) and [.NET Standard](https://docs.microsoft.com/en-us/dotnet/standard/net-standard).
- [VSCode](https://code.visualstudio.com) is recommended as IDE. [VSCode Tasks](https://code.visualstudio.com/docs/editor/tasks) are configured.
- Build automation is based on [InvokeBuild](https://github.com/nightroman/Invoke-Build)
- Test automation is based on [Pester](https://pester.dev)
- Commands are named based on [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/de-de/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)

### Build

The build scripts require InvokeBuild. If it is not installed, install it with the command `Install-Module InvokeBuild -Scope CurrentUser`.

You can build the module using the VS Code build task or with the command `Invoke-Build Build`.

### Testing

The tests scripts are based on Pester. If it is not installed, install it with the command `Install-Module -Name Pester -Force -SkipPublisherCheck`. Some tests require a SQL Server. The test creates a SQL Server in a Docker container. If needed, [install Docker](https://www.docker.com/get-started). The container are created using PSDocker, which can be installed using `Install-Module PSDocker -Scope CurrentUser`.

For local testing use the VSCode test tasks or execute the test scripts directly or with `Invoke-Pester`.
The InvokeBuild test tasks are for CI and do not generate console output.
