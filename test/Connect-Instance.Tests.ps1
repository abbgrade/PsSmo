#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PsSqlTestServer'; ModuleVersion='1.2.0' }

Describe Connect-Instance {

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
            if ( $SqlInstanceConnection ) {
                Disconnect-TSqlInstance -Connection $SqlInstanceConnection -ErrorAction Continue
            }
        }

        It 'Returns a connection by pipeline input' {
            $SmoConnection = $SqlInstanceConnection | Connect-SmoInstance

            $SmoConnection | Should -Not -BeNullOrEmpty
            $SmoConnection.Refresh()
            $SmoConnection.Edition | Should -Not -BeNullOrEmpty
            $SmoConnection.ConnectionContext.IsOpen | Should -be $true
        }

        It 'Returns a connection by property' {
            $SmoConnection = Connect-SmoInstance -Connection $SqlInstanceConnection

            $SmoConnection | Should -Not -BeNullOrEmpty
            $SmoConnection.Refresh()
            $SmoConnection.Edition | Should -Not -BeNullOrEmpty
            $SmoConnection.ConnectionContext.IsOpen | Should -be $true
        }

        AfterEach {
            if ( $SmoConnection ) {
                Disconnect-SmoInstance -Instance $SmoConnection
            }
        }
    }
}
