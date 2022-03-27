#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

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

        It 'Returns a connection by pipeline input' {
            $Script:SmoConnection = $Script:SqlInstanceConnection | Connect-SmoInstance

            $Script:SmoConnection | Should -Not -BeNullOrEmpty
            $Script:SmoConnection.Refresh()
            $Script:SmoConnection.Edition | Should -Not -BeNullOrEmpty
            $Script:SmoConnection.ConnectionContext.IsOpen | Should -be $true
        }

        It 'Returns a connection by property' {
            $Script:SmoConnection = Connect-SmoInstance -Connection $Script:SqlInstanceConnection

            $Script:SmoConnection | Should -Not -BeNullOrEmpty
            $Script:SmoConnection.Refresh()
            $Script:SmoConnection.Edition | Should -Not -BeNullOrEmpty
            $Script:SmoConnection.ConnectionContext.IsOpen | Should -be $true
        }

        AfterEach {
            if ( $Script:SmoConnection ) {
                Disconnect-SmoInstance -Instance $Script:SmoConnection
            }
        }
    }
}
