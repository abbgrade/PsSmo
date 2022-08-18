#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PsSqlTestServer'; ModuleVersion='1.2.0' }

Describe Invoke-Command {

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
    }

    Context SqlInstance {

        BeforeAll {
            $Script:SqlInstance = New-SqlTestInstance -ErrorAction Stop
            $Script:SqlInstanceConnection = $Script:SqlInstance | Connect-TSqlInstance
        }

        AfterAll {
            if ( $Script:SqlInstance ) {
                $Script:SqlInstance | Remove-SqlTestInstance
            }
            if ( $Script:SqlInstanceConnection ) {
                Disconnect-TSqlInstance -Connection $Script:SqlInstanceConnection -ErrorAction Continue
            }
        }

        Context SmoInstance {
            BeforeAll {
                $Script:SmoConnection = $Script:SqlInstanceConnection | Connect-SmoInstance -ErrorAction Stop
            }

            AfterAll {
                if ( $Script:SmoConnection ) {
                    Disconnect-SmoInstance -Instance $Script:SmoConnection
                }
            }

            It 'throws on error' {
                {
                    Invoke-SmoCommand -Command 'SELECT 1/0' -ErrorAction Stop
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
                        Invoke-SmoCommand -Command 'PRINT ''$(foo)''' -ErrorAction Stop
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
