#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Get-Table' {

    BeforeAll {
        Import-Module PsSqlClient -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
    }

    Context 'SqlInstance' {

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

        Context 'SqlDatabase' {

            BeforeAll {
                $Script:SqlDatabase = New-SqlTestDatabase -Instance $Script:SqlInstance -InstanceConnection $Script:SqlInstanceConnection -ErrorAction Stop
                $Script:SqlDatabaseConnection = $Script:SqlDatabase | Connect-TSqlInstance
            }

            AfterAll {
                Disconnect-TSqlInstance -Connection $Script:SqlDatabaseConnection
                $Script:SqlDatabase | Remove-SqlTestDatabase
            }

            Context 'SmoInstance' {
                BeforeAll {
                    $Script:SmoConnection = $Script:SqlDatabaseConnection | Connect-SmoInstance -ErrorAction Stop
                }

                AfterAll {
                    if ( $Script:SmoConnection ) {
                        Disconnect-SmoInstance -Instance $Script:SmoConnection
                    }
                }

                Context 'Table' {
                    BeforeAll {
                        Invoke-TSqlCommand 'CREATE TABLE MyTable ( [Id] INT NOT NULL PRIMARY KEY )' -Connection $Script:SqlDatabaseConnection -ErrorAction Stop
                    }

                    It 'Returns the table' {
                        $table = Get-SmoTable -Connection $Script:SmoConnection
                        $table | Should -Not -BeNullOrEmpty
                        $table.Name | Should -Be 'MyTable'
                    }

                    It 'Returns the table by name' {
                        $table = Get-SmoTable -Name 'MyTable' -Connection $Script:SmoConnection
                        $table | Should -Not -BeNullOrEmpty
                        $table.Name | Should -Be 'MyTable'
                    }
                }
            }
        }
    }
}

