#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

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

        Context 'Connection' {

            BeforeAll {
                $Script:Connection = $Script:TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Script:Connection ) {
                    Disconnect-TSqlInstance -ErrorAction Continue
                }
            }

            It 'Returns a connection' {
                $instance = $script:Connection | Connect-SmoInstance

                $instance | Should -Not -BeNullOrEmpty
                $instance.Refresh()
                $instance.Edition | Should -Not -BeNullOrEmpty
                $instance.ConnectionContext.IsOpen | Should -be $true
            }

            It 'Returns a connection by property' {
                $instance = Connect-SmoInstance -Connection $script:Connection

                $instance | Should -Not -BeNullOrEmpty
                $instance.Refresh()
                $instance.Edition | Should -Not -BeNullOrEmpty
                $instance.ConnectionContext.IsOpen | Should -be $true
            }
        }
    }
}
