@{
    RootModule = 'XWaysForensicWorkflow.psm1'
    ModuleVersion = '0.1.0'
    GUID = '99d45f07-9b5d-4270-bb62-4bb51433f893'
    Author = 'xways-mcp contributors'
    CompanyName = 'xways-mcp contributors'
    Copyright = '(c) xways-mcp contributors. All rights reserved.'
    Description = 'Container-first forensic workflow guardrails for X-Ways MCP runners.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'New-XwfForensicRun',
        'Add-XwfContemporaneousNote',
        'Get-XwfBestPracticeCatalog',
        'Select-XwfBestPractice',
        'Test-XwfManualGate',
        'Test-XwfForensicAction',
        'New-XwfQueryFirstUsagePatternPlan',
        'New-XwfContainerExportPlan',
        'New-XwfUsagePatternPlan'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('X-Ways', 'Forensics', 'DFIR', 'MCP', 'Evidence')
            ProjectUri = 'https://github.com/Donovoi/X-Ways-MCP'
            LicenseUri = 'https://github.com/Donovoi/X-Ways-MCP/blob/main/LICENSE'
        }
    }
}
