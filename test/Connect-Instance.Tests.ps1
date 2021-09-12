#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeDiscovery {
        $script:missingSqlclient = $true
        $local:psSqlclient = Get-Module -ListAvailable -Name PsSqlClient
        if ( $local:psSqlclient ) {
            Import-Module PsSqlClient
            $script:missingSqlclient = $false
        }
    }

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSmo/bin/Debug/netcoreapp2.1/publish/PsSmo.psd1 -Force -ErrorAction 'Stop'
    }

    Context 'LocalDb' -Tag LocalDb {

        BeforeAll {
            $script:missingLocalDb = $true
            foreach( $version in Get-ChildItem -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions' | Sort-Object Name -Descending ) {
                if ( $script:missingLocalDb ) {
                    switch ( $version.PSChildName ) {
                        '11.0' {
                            $script:DataSource = '(localdb)\v11.0'
                            $script:missingLocalDb = $false
                            break;
                        }
                        '13.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $script:missingLocalDb = $false
                            break;
                        }
                        '15.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $script:missingLocalDb = $false
                            break;
                        }
                        Default {
                            Write-Warning "LocalDb version $_ is not implemented."
                        }
                    }
                }
            }
        }

        AfterEach {
            if ( $script:Instance ) {
                $script:Instance | Disconnect-SmoInstance
            }
        }

        Context 'SqlClient' -Skip:$script:missingSqlclient {

            BeforeAll {
                $script:Connection = Connect-TSqlInstance -DataSource $script:DataSource
            }

            AfterAll {
                if ( $script:Connection ) {
                    $script:Connection | Disconnect-TSqlInstance
                }
            }

            It 'Returns a connection' {
                $script:Instance = $script:Connection | Connect-SmoInstance

                $script:Instance | Should -Not -BeNullOrEmpty
                $script:Instance.Refresh()
                $script:Instance.Edition | Should -Not -BeNullOrEmpty
                $script:Instance.ConnectionContext.IsOpen | Should -be $true
            }

            It 'Returns a connection by property' {
                $script:Instance = Connect-SmoInstance -Connection $script:Connection

                $script:Instance | Should -Not -BeNullOrEmpty
                $script:Instance.Refresh()
                $script:Instance.Edition | Should -Not -BeNullOrEmpty
                $script:Instance.ConnectionContext.IsOpen | Should -be $true
            }
        }
    }
}
