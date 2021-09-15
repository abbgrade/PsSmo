requires Configuration

[System.IO.FileInfo] $global:Manifest = "$PSScriptRoot/../src/PsSmo/bin/$Configuration/netcoreapp2.1/publish/PsSmo.psd1"

# Synopsis: Build project.
task Build {
	exec { dotnet publish ./src/PsSmo -c $Configuration }
}

# Synopsis: Remove temporary files.
task Clean {
	remove src/PsSmo/bin, src/PsSmo/obj
}

# Synopsis: Generate documentation.
task Docs -Jobs Build, {
	Import-Module $global:Manifest

	if ( Test-Path ./docs -PathType Container ) {
		Update-MarkdownHelp ./docs
	} else {
		New-MarkdownHelp -Module PsSmo -OutputFolder ./docs
	}
}

# Synopsis: Install the module.
task Install -Jobs Build, {
    $info = Import-PowerShellDataFile $global:Manifest.FullName
    $version = ([System.Version] $info.ModuleVersion)
    $name = $global:Manifest.BaseName
    $defaultModulePath = $env:PsModulePath -split ';' | Select-Object -First 1
    $installPath = Join-Path $defaultModulePath $name $version.ToString()
    New-Item -Type Directory $installPath -Force | Out-Null
    Get-ChildItem $global:Manifest.Directory | Copy-Item -Destination $installPath -Recurse -Force
}

# Synopsis: Publish the module to PSGallery.
task Publish -Jobs Install, {

	assert ( $Configuration -eq 'Release' )

	Publish-Module -Name PsSmo -NuGetApiKey $NuGetApiKey
}
