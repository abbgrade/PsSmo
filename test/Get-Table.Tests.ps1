#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Get-Table' {

    BeforeDiscovery {
        $Script:PsSqlClient = Import-Module PsSqlClient -PassThru -ErrorAction SilentlyContinue
    }

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSmo/PsSmo.psd1 -Force -ErrorAction Stop
    }

    Context 'SqlClient' -Skip:( -Not ( $Script:PsSqlClient )) {

        BeforeAll {
            $Script:DataSource = '(LocalDb)\MSSQLLocalDB'
            $script:ServerConnection = Connect-TSqlInstance -DataSource $Script:DataSource -ErrorAction Stop
        }

        AfterAll {
            if ( $script:ServerConnection ) {
                Disconnect-TSqlInstance -Connection $script:ServerConnection
            }
        }

        Context 'TestDatabase' {

            BeforeAll {
                [string] $Script:DatabaseName = ( [string](New-Guid) ).Substring(0, 8)
                Invoke-TSqlCommand "CREATE DATABASE [$Script:DatabaseName]" -Connection $script:ServerConnection -ErrorAction Stop
                $Script:TestConnection = Connect-TSqlInstance -DataSource $Script:DataSource -InitialCatalog $Script:DatabaseName
            }

            AfterAll {
                Invoke-TSqlCommand 'USE [master];' -Connection $Script:TestConnection
                Disconnect-TSqlInstance -Connection $Script:TestConnection
                Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName]" -Connection $script:ServerConnection
            }

            Context 'SmoInstance' {
                BeforeAll {
                    $Script:ManagementConnection = Connect-SmoInstance -Connection $Script:TestConnection -ErrorAction Stop
                }

                AfterAll {
                    if ( $Script:ManagementConnection )
                    {
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
