<#
.Synopsis
	Build script <https://github.com/nightroman/Invoke-Build>
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string] $Configuration = 'Debug',

	[string] $NuGetApiKey = $env:nuget_apikey
)

. $PSScriptRoot\tasks\Build.Tasks.ps1

# Synopsis: Default task.
task . Build
