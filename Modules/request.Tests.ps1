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

Describe "Get-UUPFiles" {
    Context "When Id is provided" {
        It "Should return non-null hashtable" {
            $result = Get-UUPFiles -Id "8c10c883-071c-43c3-bff8-8ed82fba2436"
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'System.Collections.Hashtable'
            $result.Keys | Should -Contain "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
        }
    }
}

Describe "Get-UUPFile" {
    Context "When Id and FileName are provided" {
        It "Should return file details" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'PSCustomObject'
            $result.url | Should -Match '^https?://'
            $result.size | Should -BeGreaterThan 0
            $result.sha1 | Should -Match '^[a-fA-F0-9]{40}$'
        }
        It "Should hit the cache on second call" {
            $fileName = "Microsoft-Windows-WirelessDisplay-FOD-Package-x86.cab"
            # First call to populate cache
            $null = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            # Second call should hit cache
            $result = Get-UUPFile -Id "8c10c883-071c-43c3-bff8-8ed82fba2436" -FileName $fileName
            $result | Should -Not -Be $null
            $result | Should -BeOfType 'PSCustomObject'
        }
    }
}