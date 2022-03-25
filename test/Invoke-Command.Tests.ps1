#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Invoke-Command' {

    BeforeAll {
        Import-Module PsSqlClient -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
    }

    Context 'TestInstance' {

        BeforeAll {
            $Script:TestInstance = New-SqlTestInstance -ErrorAction Stop
        }

        AfterAll {
            $Script:TestInstance | Remove-SqlTestInstance
        }

        Context 'Connection' {

            BeforeAll {
                $Script:Connection = $Script:TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Script:Connection ) {
                    Disconnect-TSqlInstance -ErrorAction Continue
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
