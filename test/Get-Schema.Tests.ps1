#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PsSqlTestServer'; ModuleVersion='1.2.0' }

Describe Get-Schema {

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

                Context Schema {
                    BeforeAll {
                        Invoke-TSqlCommand 'CREATE Schema MySchema' -Connection $SqlDatabaseConnection -ErrorAction Stop
                    }

                    It 'Returns the Schema' {
                        $Schemas = Get-SmoSchema -Connection $SmoConnection
                        $Schemas | Should -Not -BeNullOrEmpty
                        $Schemas.Name | Should -Contain 'MySchema'
                    }

                    It 'Returns the Schema by name' {
                        $Schema = Get-SmoSchema -Name 'MySchema' -Connection $SmoConnection
                        $Schema | Should -Not -BeNullOrEmpty
                        $Schema.Name | Should -Be 'MySchema'
                    }
                }
            }
        }
    }
}

