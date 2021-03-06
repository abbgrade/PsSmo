task InstallBuildDependencies -Jobs {
    Install-Module platyPs -Scope CurrentUser -ErrorAction Stop -Verbose
}

task InstallTestDependencies -Jobs {
    Install-Module PsSqlClient -Scope CurrentUser -ErrorAction Stop -AllowPrerelease -AllowClobber -Verbose
    Install-Module PsSqlLocalDb -Scope CurrentUser -AllowPrerelease -Verbose
    Install-Module psdocker -Scope CurrentUser -AllowPrerelease -Verbose
    Install-Module PsSqlTestServer -Scope CurrentUser -AllowPrerelease -Verbose
}

task InstallReleaseDependencies -Jobs {
}
