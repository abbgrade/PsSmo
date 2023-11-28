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

            Context ScriptWithError {

                BeforeAll {
                    $Command = @'
SELECT 1/0
PRINT 'foo'
GO
PRINT 'bar'
'@
                }

                It 'stops on error' {
                    {
                        $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput 4>&1
                    } | Should -Throw 'An exception occurred while executing a Transact-SQL statement or batch.'
                    # $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    # $InformationOutput[0].MessageData | Should -Be "SELECT 1/0`r`nPRINT 'foo'`r`n"
                }

                It 'continues on error' {
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction SilentlyContinue -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be "SELECT 1/0`r`nPRINT 'foo'`r`n"
                    $ErrorOutput[0].Exception.Message | Should -Be 'An exception occurred while executing a Transact-SQL statement or batch.'
                    $ErrorOutput[0].Exception.InnerException.Errors[0].Message | Should -Be 'Divide by zero error encountered.'
                    # $InformationOutput[1].MessageData | Should -Be "PRINT 'bar'`r`n" # still a bug
                }
            }

            Context ScriptWithTransactionError {

                BeforeAll {
                    $Command = @'
:on error exit
GO

BEGIN TRANSACTION MIGRATION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON
GO
PRINT 'bar'
'@
                }

                It 'stops on error' {
                    # {
                        $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput 4>&1
                    # } | Should -Throw 'An exception occurred while executing a Transact-SQL statement or batch.'
                    # $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    # $InformationOutput[0].MessageData | Should -Be "SELECT 1/0`r`nPRINT 'foo'`r`n"
                }

                It 'continues on error' {
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction SilentlyContinue -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $WarningOutput[0].Message | Should -Be ':on error is not implemented'
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be @"

BEGIN TRANSACTION MIGRATION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON

"@
                    $InformationOutput[1].MessageData | Should -Be "PRINT 'bar'"
                    $VerboseOutput[1].Message | Should -Be 'bar'
                }
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

PRINT 'foo'
'@ | Should -BeNullOrEmpty
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
