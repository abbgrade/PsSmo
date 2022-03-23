task InstallBuildDependencies -Jobs {
    Install-Module platyPs -ErrorAction Stop -Verbose
}

task InstallTestDependencies -Jobs {
    Install-Module PsSqlClient, PsSqlTestServer, psdocker -ErrorAction Stop -Verbose
}

task InstallReleaseDependencies -Jobs {
}
