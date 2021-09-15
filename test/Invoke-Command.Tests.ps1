Describe 'Invoke-Command' {

    BeforeDiscovery {
        $script:missingSqlclient = $true
        $local:psSqlclient = Get-Module -ListAvailable -Name PsSqlClient
        if ( $local:psSqlclient ) {
            Import-Module PsSqlClient
            $script:missingSqlclient = $false
        }
    }

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSmo/bin/Debug/netcoreapp2.1/publish/PsSmo.psd1 -Force -ErrorAction 'Stop'
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

        Context 'SqlClient' -Skip:$script:missingSqlclient {

            BeforeAll {
                $script:Connection = Connect-TSqlInstance -DataSource $script:DataSource
            }

            AfterAll {
                if ( $script:Connection ) {
                    $script:Connection | Disconnect-TSqlInstance
                }
            }

            Context 'SmoInstance' {
                BeforeAll {
                    $script:Instance = $script:Connection | Connect-SmoInstance
                }

                AfterAll {
                    $script:Instance | Disconnect-SmoInstance
                }

                It 'works' {
                    Invoke-SmoCommand -Command 'SELECT 1'
                }

                It 'returns select' {
                    ( Invoke-SmoCommand -Command 'SELECT 1 as col' ).col | Should -Be '1'
                }

                It 'works with separator' {
                    Invoke-SmoCommand -Command @'
SELECT 1
GO

SELECT 2
GO
'@
                }

                It 'works with two results' {
                    $result = Invoke-SmoCommand -Command @'
SELECT 1 AS a

SELECT 2 AS b
'@
                    $result[0].a | Should -Be 1
                    $result[1].b | Should -Be 2
                }

                It 'works with variables' {
                    Invoke-SmoCommand -Command 'SELECT ''$(foo)'''
                }

                It 'throws on error' {
                    {
                        Invoke-SmoCommand -Command 'SELECT 1/0'
                    } | Should -Throw
                }
            }
        }
    }

}
