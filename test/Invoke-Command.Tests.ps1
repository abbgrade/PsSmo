#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Invoke-Command' {

    BeforeDiscovery {
        $Script:PsSqlClient = Import-Module PsSqlClient -MaximumVersion '0.4.0' -PassThru -ErrorAction SilentlyContinue
    }

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
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

        Context 'SqlClient' -Skip:( -Not ( $Script:PsSqlClient )) {

            BeforeAll {
                $script:Connection = Connect-TSqlInstance -DataSource $script:DataSource
            }

            AfterAll {
                if ( $script:Connection ) {
                    Disconnect-TSqlInstance -Connection $script:Connection
                }
            }

            Context 'SmoInstance' {
                BeforeAll {
                    $script:Instance = $script:Connection | Connect-SmoInstance -ErrorAction Stop
                }

                AfterAll {
                    Disconnect-SmoInstance -Instance $script:Instance
                }

                It 'throws on error' {
                    {
                        Invoke-SmoCommand -Command 'SELECT 1/0'
                    } | Should -Throw
                }

                Context 'SQLCMD' {

                    It 'works with separator' {
                        Invoke-SmoCommand -Command @'
PRINT 'foo'
GO

PRINT 'bar'
GO
'@
                    }

                    It 'throws with undefined variables' {
                        {
                            Invoke-SmoCommand -Command 'PRINT ''$(foo)'''
                        } | Should -Throw
                    }

                    It 'works with defined variables' {
                        Invoke-SmoCommand -Command 'PRINT ''$(foo)''' -Variables @{ foo = 'bar' } -Verbose
                    }

                    It 'works with :on error' {
                        Invoke-SmoCommand -Command @'
GO
:on error exit
GO
'@
                    }

                    It 'works with :setvar' {
                        Invoke-SmoCommand -Command @'
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END
'@
                    }

                    It 'ignores line comments' {
                        Invoke-SmoCommand -Command @'
-- :setvar foo $(foo)
PRINT '$(foo)'
'@ -Variables @{ foo = 'bar' }
                    }

                    It 'ignores block comments' {
                        Invoke-SmoCommand -Command @'
/*
:setvar foo $(foo)
*/
PRINT '$(foo)'
'@ -Variables @{ foo = 'bar' }
                    }
                }
            }
        }
    }

}
