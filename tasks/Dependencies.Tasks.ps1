task InstallBuildDependencies -Jobs {
    Install-Module platyPs -ErrorAction Stop
}

task InstallTestDependencies -Jobs {
    Install-Module PsSqlClient, PsSqlTestServer, psdocker -ErrorAction Stop
}, Testdata.Create

task InstallReleaseDependencies -Jobs {
}
