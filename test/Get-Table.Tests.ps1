#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Get-Table' {

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

        Context 'ServerConnection' {

            BeforeAll {
                $Script:ServerConnection = $Script:TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Script:ServerConnection ) {
                    Disconnect-TSqlInstance -ErrorAction Continue
                }
            }

            Context 'TestDatabase' {

                BeforeAll {
                    [string] $Script:DatabaseName = ( [string](New-Guid) ).Substring(0, 8)
                    Invoke-TSqlCommand "CREATE DATABASE [$Script:DatabaseName]" -Connection $script:ServerConnection -ErrorAction Stop
                    $Script:TestConnection = Connect-TSqlInstance -DataSource $Script:ServerConnection.DataSource -InitialCatalog $Script:DatabaseName
                }

                AfterAll {
                    Invoke-TSqlCommand 'USE [master];' -Connection $Script:ServerConnection
                    Disconnect-TSqlInstance -Connection $Script:ServerConnection
                    Invoke-TSqlCommand "ALTER DATABASE [$Script:DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE" -Connection $script:ServerConnection
                    Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName]" -Connection $script:ServerConnection
                }

                Context 'SmoInstance' {
                    BeforeAll {
                        $Script:ManagementConnection = Connect-SmoInstance -Connection $Script:TestConnection -ErrorAction Stop
                    }

                    AfterAll {
                        if ( $Script:ManagementConnection ) {
                            Disconnect-SmoInstance -Instance $Script:ManagementConnection
                        }
                    }

                    Context 'Table' {
                        BeforeAll {
                            Invoke-TSqlCommand 'CREATE TABLE MyTable ( [Id] INT NOT NULL PRIMARY KEY )' -Connection $Script:TestConnection -ErrorAction Stop
                        }

                        It 'Returns the table' {
                            $table = Get-SmoTable -Connection $Script:ManagementConnection
                            $table | Should -Not -BeNullOrEmpty
                            $table.Name | Should -Be 'MyTable'
                        }

                        It 'Returns the table by name' {
                            $table = Get-SmoTable -Name 'MyTable' -Connection $Script:ManagementConnection
                            $table | Should -Not -BeNullOrEmpty
                            $table.Name | Should -Be 'MyTable'
                        }
                    }
                }
            }
        }
    }
}
