task InstallBuildDependencies -Jobs {
    Install-Module platyPs -Scope CurrentUser -ErrorAction Stop -Verbose
}

task InstallTestDependencies -Jobs {
    Install-Module PsSqlTestServer -Scope CurrentUser -AllowPrerelease -Verbose
    Install-Module psdocker -Scope CurrentUser -AllowPrerelease -Verbose
    Install-Module PsSqlLocalDb -Scope CurrentUser -AllowPrerelease -Verbose
    Install-Module PsSqlClient -Scope CurrentUser -ErrorAction Stop -MaximumVersion '0.4.0' -Verbose
}

task InstallReleaseDependencies -Jobs {
}
