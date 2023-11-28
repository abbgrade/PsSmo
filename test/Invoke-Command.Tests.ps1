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
                        $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    } | Should -Throw 'An exception occurred while executing a Transact-SQL statement or batch.'
                    # $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    # $InformationOutput[0].MessageData | Should -Be "SELECT 1/0`r`nPRINT 'foo'"
                }

                It 'continues on error' {
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction SilentlyContinue -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be "SELECT 1/0`r`nPRINT 'foo'"
                    $ErrorOutput[0].Exception.Message | Should -Be 'An exception occurred while executing a Transact-SQL statement or batch.'
                    $ErrorOutput[0].Exception.InnerException.Errors[0].Message | Should -Be 'Divide by zero error encountered.'
                    # $InformationOutput[1].MessageData | Should -Be "PRINT 'bar'" # still a bug
                    # $VerboseOutput[1].Message | Should -Be 'bar'
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
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1

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
                    $Command = @'
PRINT 'foo'
GO

PRINT 'bar'
GO
'@
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be "PRINT 'foo'"
                    $VerboseOutput[1].Message | Should -Be 'foo'
                    $InformationOutput[1].MessageData | Should -Be "PRINT 'bar'"
                    $VerboseOutput[2].Message | Should -Be 'bar'
                }

                Context ScriptWithVariable {
                    BeforeAll {
                        $Command = 'PRINT ''$(foo)'''
                    }

                    It 'throws with undefined variables' {
                        {
                            $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                        } | Should -Throw 'Value for variable $(foo) was not given.'
                    }

                    It 'works with defined variables' {
                        $VerboseOutput = Invoke-SmoCommand -Command $Command -Variables @{ foo = 'bar' } -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                        $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                        $InformationOutput[0].MessageData | Should -Be "PRINT 'bar'"
                        $VerboseOutput[1].Message | Should -Be 'bar'
                    }
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
                    $Command = @'
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END
'@
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be @"
IF N'True' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END
"@
                }

                It 'ignores line comments' {
                    $Command = @'
-- :setvar foo $(foo)
PRINT '$(foo)'
'@
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -Variables @{ foo = 'bar' } -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be "PRINT 'bar'"
                    $VerboseOutput[1].Message | Should -Be 'bar'
                }

                It 'ignores block comments' {
                    $Command = @'
/*
:setvar foo $(foo)
*/
PRINT '$(foo)'
'@
                    $VerboseOutput = Invoke-SmoCommand -Command $Command -Variables @{ foo = 'bar' } -ErrorAction Stop -ErrorVariable ErrorOutput -Verbose -InformationVariable InformationOutput -WarningAction SilentlyContinue -WarningVariable WarningOutput 4>&1
                    $VerboseOutput[0].Message | Should -Be 'Execute SQL script from text.'
                    $InformationOutput[0].MessageData | Should -Be "PRINT 'bar'"
                    $VerboseOutput[1].Message | Should -Be 'bar'
                }
            }
        }
    }
}
