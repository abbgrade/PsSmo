@{
    RootModule = 'PsSmo.dll'
    ModuleVersion = '0.5.0'
    DefaultCommandPrefix = 'Smo'
    PowerShellVersion = '7.0'

    GUID = 'e800d6be-fb78-4e78-8c9e-a80fce7a139c'
    Author = 'Steffen Kampmann'
    Copyright = '(c) 2021 Steffen Kampmann. Alle Rechte vorbehalten.'
    Description = 'The PowerShell SQL Client module replaces the SQL Server utilities SQLCMD with native PowerShell commands.'

    CmdletsToExport = @(
        'Connect-Instance',
        'Disconnect-Instance',
        'Invoke-Command'
    )

    PrivateData = @{

        PSData = @{
            Category = 'Databases'
            Tags = @('sql', 'sqlserver', 'sqlclient')
            LicenseUri = 'https://github.com/abbgrade/PsSmo/blob/main/LICENSE'
            ProjectUri = 'https://github.com/abbgrade/PsSmo'
            IsPrerelease = 'True'
        }
    }
}
