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
        'New-XwfUsagePatternPlan',
        'Get-XwfPortableExecutable',
        'Get-XwfPeExternalFunction',
        'Get-XwfPeExport',
        'Get-XwfApiString',
        'Compare-XwfExternalSurface',
        'Export-XwfExternalSurfaceReport',
        'Get-XwfApiCatalog',
        'Test-XwfApiInvocation',
        'Invoke-XwfApiFunction',
        'Get-XwfColumnTitle',
        'Get-XwfWindow',
        'Remove-XwfMemoryAllocation',
        'Hide-XwfProgress',
        'Test-XwfStopRequested',
        'Set-XwfProgressDescription',
        'Set-XwfProgressPercentage',
        'Show-XwfProgress',
        'Get-XwfUserInput',
        'Write-XwfMessage',
        'Get-XwfEvent',
        'Add-XwfEvent',
        'Invoke-XwfSearchTermAction',
        'Add-XwfSearchTerm',
        'Get-XwfSearchTerm',
        'Search-XwfItem',
        'Get-XwfEvidenceObjectReportTableAssociation',
        'Get-XwfReportTableInfo',
        'Get-XwfEvidenceObject',
        'Get-XwfEvidenceObjectProperty',
        'Close-XwfEvidenceObject',
        'Open-XwfEvidenceObject',
        'New-XwfEvidenceObject',
        'Get-XwfNextEvidenceObject',
        'Get-XwfFirstEvidenceObject',
        'Get-XwfCaseProperty',
        'New-XwfContainer',
        'Close-XwfContainer',
        'Copy-XwfItemToContainer',
        'Get-XwfRasterImage',
        'Get-XwfText',
        'Initialize-XwfTextAccess',
        'Get-XwfExtendedMetadata',
        'Get-XwfMetadata',
        'Get-XwfCellText',
        'Set-XwfHashValue',
        'Get-XwfHashValue',
        'Add-XwfExtractedMetadata',
        'Get-XwfExtractedMetadata',
        'Add-XwfComment',
        'Get-XwfComment',
        'Add-XwfReportTableEntry',
        'Set-XwfItemLabel',
        'Get-XwfReportTableAssociation',
        'Get-XwfLabels',
        'Get-XwfHashSetAssociation',
        'Set-XwfItemParent',
        'Get-XwfItemParent',
        'Set-XwfItemType',
        'Get-XwfItemType',
        'Set-XwfItemInformation',
        'Get-XwfItemInformation',
        'Set-XwfItemOffset',
        'Get-XwfItemOffset',
        'Set-XwfItemSize',
        'Get-XwfItemSize',
        'Get-XwfItemName',
        'Dismount-XwfVolume',
        'Mount-XwfVolume',
        'Find-XwfItem',
        'New-XwfFile',
        'New-XwfItem',
        'Get-XwfFileCount',
        'Get-XwfItemCount',
        'Get-XwfVolumeSnapshotProperty',
        'Select-XwfVolumeSnapshot',
        'Invoke-XwfSectorIo',
        'Read-XwfContent',
        'Close-XwfContext',
        'Open-XwfItem',
        'Get-XwfSectorContents',
        'Set-XwfBlock',
        'Get-XwfBlock',
        'Get-XwfVolumeInformation',
        'Get-XwfVolumeName',
        'Get-XwfProperty',
        'Get-XwfSize'
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
