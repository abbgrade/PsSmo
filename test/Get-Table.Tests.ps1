#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PsSqlTestServer'; ModuleVersion='1.2.0' }

Describe Get-Table {

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
    }

    Context SqlInstance {

        BeforeAll {
            $SqlInstance = New-SqlTestInstance -ErrorAction Stop
            $SqlInstanceConnection = $SqlInstance | Connect-TSqlInstance
        }

        AfterAll {
            if ( $SqlInstance ) {
                $SqlInstance | Remove-SqlTestInstance
            }
        }

        Context SqlDatabase {

            BeforeAll {
                $SqlDatabase = New-SqlTestDatabase -Instance $SqlInstance -InstanceConnection $SqlInstanceConnection -ErrorAction Stop
                $SqlDatabaseConnection = $SqlDatabase | Connect-TSqlInstance
            }

            AfterAll {
                Disconnect-TSqlInstance -Connection $SqlDatabaseConnection
                $SqlDatabase | Remove-SqlTestDatabase
            }

            Context SmoInstance {
                BeforeAll {
                    $SmoConnection = $SqlDatabaseConnection | Connect-SmoInstance -ErrorAction Stop
                }

                AfterAll {
                    if ( $SmoConnection ) {
                        Disconnect-SmoInstance -Instance $SmoConnection
                    }
                }

                Context Table {
                    BeforeAll {
                        Invoke-TSqlCommand 'CREATE TABLE MyTable ( [Id] INT NOT NULL PRIMARY KEY )' -Connection $SqlDatabaseConnection -ErrorAction Stop
                    }

                    It 'Returns the table' {
                        $table = Get-SmoTable -Connection $SmoConnection
                        $table | Should -Not -BeNullOrEmpty
                        $table.Name | Should -Be 'MyTable'
                    }

                    It 'Returns the table by name' {
                        $table = Get-SmoTable -Name 'MyTable' -Connection $SmoConnection
                        $table | Should -Not -BeNullOrEmpty
                        $table.Name | Should -Be 'MyTable'
                    }
                }
            }
        }
    }
}

