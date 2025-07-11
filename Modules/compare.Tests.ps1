# Requires -Modules Pester
Import-Module Pester

BeforeAll {
    # Import the module to test
    Import-Module "$PSScriptRoot/compare.psm1"
}

AfterAll {
    Remove-Module compare
}

Describe "Compare-Version" {
    It "returns $true when LatestVersion is greater than CurrentVersion" {
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "26100.2345" | Should -Be $true
        Compare-Version -CurrentVersion "19045.1" -LatestVersion "19045.123" | Should -Be $true
        Compare-Version -CurrentVersion "17763.123" -LatestVersion "17763.8765" | Should -Be $true
    }

    It "returns $false when LatestVersion is equal to CurrentVersion" {
        Compare-Version -CurrentVersion "26100.1" -LatestVersion "26100.1" | Should -Be $false
        Compare-Version -CurrentVersion "19045.1234" -LatestVersion "19045.1234" | Should -Be $false
    }

    It "returns $false when LatestVersion is less than CurrentVersion" {
        Compare-Version -CurrentVersion "26100.2345" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "19045.123" -LatestVersion "19045.1" | Should -Be $false
        Compare-Version -CurrentVersion "17763.8765" -LatestVersion "17763.123" | Should -Be $false
    }

    It "returns $false when either version is null or empty" {
        Compare-Version -CurrentVersion "" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "" | Should -Be $false
        Compare-Version -CurrentVersion $null -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion $null | Should -Be $false
    }

    It "returns $false and writes error when version strings are invalid" {
        Compare-Version -CurrentVersion "abc" -LatestVersion "26100.1234" | Should -Be $false
        Compare-Version -CurrentVersion "26100.1234" -LatestVersion "xyz" | Should -Be $false
        Compare-Version -CurrentVersion "foo" -LatestVersion "bar" | Should -Be $false
    }
}
