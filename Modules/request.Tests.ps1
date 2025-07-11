# Requires -Modules Pester
Import-Module Pester

BeforeAll {
    # Import the module to test
    Import-Module "$PSScriptRoot/request.psm1"
}

AfterAll {
    Remove-Module request
}

Describe "Request-Update" {
    Context "When QueryString is regex pattern" {
        It "Should return version in format number.number" {
            $result = Request-Update -QueryString "regex:^(?:(?!Insider|Server|HCI).)*26100"
            $result | Should -Match '^26100\.\d+$'
        }
    }

    Context "When Category is w11-24h2" {
        It "Should return version in format number.number" {
            $result = Request-Update -Category "w11-24h2"
            $result | Should -Match '^26100\.\d+$'
        }
    }

    Context "When Category is w10-22h2" {
        It "Should return version in format number.number" {
            $result = Request-Update -Category "w10-22h2"
            $result | Should -Match '^19045\.\d+$'
        }
    }

    Context "When Category is w11-19h2" {
        It "Should throw an error" {
            { Request-Update -Category "w11-19h2" } | Should -Throw
        }
    }
}
