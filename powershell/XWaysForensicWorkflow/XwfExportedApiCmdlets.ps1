# This file is generated from data/xwf-external-surface/xwf-21.8-exported-api-cmdlets.csv.
# Keep the exact XWF_* API names in requests; wrappers must not call native exports directly.

function Get-XwfColumnTitle {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetColumnTitle.

    .DESCRIPTION
    Get-XwfColumnTitle maps one-to-one to the verified X-Ways export
    XWF_GetColumnTitle. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_GetColumnTitle( WORD nWndNo, WORD nColIndex, LPWSTR lpBuffer );

    Documented parameter names: nWndNo;nColIndex;lpBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfColumnTitle -Argument @{ nWndNo = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetColumnTitle' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfWindow {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetWindow.

    .DESCRIPTION
    Get-XwfWindow maps one-to-one to the verified X-Ways export XWF_GetWindow.
    It does not load or call the X-Ways executable. It validates arguments
    against the local catalog and emits an xwf-api-bridge-request/v1 object,
    optionally appending that request to a JSONL outbox for an in-process
    X-Tension bridge.

    Native signature:
    HWND XWF_GetWindow( WORD nWndNo, WORD nWndIndex );

    Documented parameter names: nWndNo;nWndIndex
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfWindow -Argument @{ nWndNo = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetWindow' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Remove-XwfMemoryAllocation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_ReleaseMem.

    .DESCRIPTION
    Remove-XwfMemoryAllocation maps one-to-one to the verified X-Ways export
    XWF_ReleaseMem. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    BOOL XWF_ReleaseMem( PVOID lpBuffer );

    Documented parameter names: lpBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Remove-XwfMemoryAllocation -Argument @{ lpBuffer = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_ReleaseMem' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Hide-XwfProgress {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_HideProgress.

    .DESCRIPTION
    Hide-XwfProgress maps one-to-one to the verified X-Ways export
    XWF_HideProgress. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    VOID XWF_HideProgress( );

    Documented parameter names: No documented parameters captured.
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Hide-XwfProgress -Argument @{} -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_HideProgress' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Test-XwfStopRequested {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_ShouldStop.

    .DESCRIPTION
    Test-XwfStopRequested maps one-to-one to the verified X-Ways export
    XWF_ShouldStop. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    BOOL XWF_ShouldStop( );

    Documented parameter names: No documented parameters captured.
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Test-XwfStopRequested -Argument @{} -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_ShouldStop' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfProgressDescription {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetProgressDescription.

    .DESCRIPTION
    Set-XwfProgressDescription maps one-to-one to the verified X-Ways export
    XWF_SetProgressDescription. It does not load or call the X-Ways executable.
    It validates arguments against the local catalog and emits an xwf-api-
    bridge-request/v1 object, optionally appending that request to a JSONL
    outbox for an in-process X-Tension bridge.

    Native signature:
    VOID XWF_SetProgressDescription( LPWSTR lpStr );

    Documented parameter names: lpStr
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfProgressDescription -Argument @{ lpStr = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetProgressDescription' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfProgressPercentage {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetProgressPercentage.

    .DESCRIPTION
    Set-XwfProgressPercentage maps one-to-one to the verified X-Ways export
    XWF_SetProgressPercentage. It does not load or call the X-Ways executable.
    It validates arguments against the local catalog and emits an xwf-api-
    bridge-request/v1 object, optionally appending that request to a JSONL
    outbox for an in-process X-Tension bridge.

    Native signature:
    VOID XWF_SetProgressPercentage( DWORD nPercent );

    Documented parameter names: nPercent
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfProgressPercentage -Argument @{ nPercent = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetProgressPercentage' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Show-XwfProgress {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_ShowProgress.

    .DESCRIPTION
    Show-XwfProgress maps one-to-one to the verified X-Ways export
    XWF_ShowProgress. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    VOID XWF_ShowProgress( LPWSTR lpCaption, DWORD nFlags );

    Documented parameter names: lpCaption;nFlags
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Show-XwfProgress -Argument @{ lpCaption = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_ShowProgress' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfUserInput {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetUserInput.

    .DESCRIPTION
    Get-XwfUserInput maps one-to-one to the verified X-Ways export
    XWF_GetUserInput. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetUserInput( LPWSTR lpMessage, LPWSTR lpBuffer, DWORD nBufferLen,
    DWORD nFlags );

    Documented parameter names: lpMessage;lpBuffer;nBufferLen;nFlags
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfUserInput -Argument @{ lpMessage = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetUserInput' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Write-XwfMessage {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_OutputMessage.

    .DESCRIPTION
    Write-XwfMessage maps one-to-one to the verified X-Ways export
    XWF_OutputMessage. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    VOID XWF_OutputMessage( LPWSTR lpMessage, DWORD nFlags );

    Documented parameter names: lpMessage;nFlags
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Write-XwfMessage -Argument @{ lpMessage = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_OutputMessage' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfEvent {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetEvent.

    .DESCRIPTION
    Get-XwfEvent maps one-to-one to the verified X-Ways export XWF_GetEvent. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_GetEvent( DWORD nEventNo, struct EventInfo* pEvt );

    Documented parameter names: nEventNo;pEvt
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfEvent -Argument @{ nEventNo = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetEvent' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Add-XwfEvent {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_AddEvent.

    .DESCRIPTION
    Add-XwfEvent maps one-to-one to the verified X-Ways export XWF_AddEvent. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_AddEvent( struct EventInfo* pEvt );

    Documented parameter names: pEvt
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Add-XwfEvent -Argument @{ pEvt = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_AddEvent' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Invoke-XwfSearchTermAction {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_ManageSearchTerm.

    .DESCRIPTION
    Invoke-XwfSearchTermAction maps one-to-one to the verified X-Ways export
    XWF_ManageSearchTerm. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_ManageSearchTerm( LONG nSearchTermID , LONG nProperty , LPVOID
    pValue );

    Documented parameter names: nSearchTermID;nProperty;pValue
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Invoke-XwfSearchTermAction -Argument @{ nSearchTermID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_ManageSearchTerm' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Add-XwfSearchTerm {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_AddSearchTerm.

    .DESCRIPTION
    Add-XwfSearchTerm maps one-to-one to the verified X-Ways export
    XWF_AddSearchTerm. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_AddSearchTerm( LPWSTR lpSearchTerm, DWORD nUsageFlags );

    Documented parameter names: lpSearchTerm;nUsageFlags
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Add-XwfSearchTerm -Argument @{ lpSearchTerm = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_AddSearchTerm' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfSearchTerm {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetSearchTerm.

    .DESCRIPTION
    Get-XwfSearchTerm maps one-to-one to the verified X-Ways export
    XWF_GetSearchTerm. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPWSTR XWF_GetSearchTerm( LONG nSearchTermID , LPVOID pReserved );

    Documented parameter names: nSearchTermID;pReserved
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfSearchTerm -Argument @{ nSearchTermID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetSearchTerm' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Search-XwfItem {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Search.

    .DESCRIPTION
    Search-XwfItem maps one-to-one to the verified X-Ways export XWF_Search. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_Search( struct SearchInfo* pSInfo struct CodePages* pCPages );

    Documented parameter names: pCPages
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Search-XwfItem -Argument @{ pCPages = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Search' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfEvidenceObjectReportTableAssociation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetEvObjReportTableAssocs.

    .DESCRIPTION
    Get-XwfEvidenceObjectReportTableAssociation maps one-to-one to the verified
    X-Ways export XWF_GetEvObjReportTableAssocs. It does not load or call the
    X-Ways executable. It validates arguments against the local catalog and
    emits an xwf-api-bridge-request/v1 object, optionally appending that request
    to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LPVOID XWF_GetEvObjReportTableAssocs( HANDLE hEvidence, LONG nFlags, PLONG
    lpValue );

    Documented parameter names: hEvidence;nFlags;lpValue
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfEvidenceObjectReportTableAssociation -Argument @{ hEvidence = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetEvObjReportTableAssocs' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfReportTableInfo {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetReportTableInfo.

    .DESCRIPTION
    Get-XwfReportTableInfo maps one-to-one to the verified X-Ways export
    XWF_GetReportTableInfo. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPVOID XWF_GetReportTableInfo( LPVOID pReserved, LONG nReportTableID, PLONG
    lpOptional );

    Documented parameter names: pReserved;nReportTableID;lpOptional
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfReportTableInfo -Argument @{ pReserved = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetReportTableInfo' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetEvObj.

    .DESCRIPTION
    Get-XwfEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_GetEvObj. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    HANDLE XWF_GetEvObj( DWORD nEvObjID, );

    Documented parameter names: nEvObjID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfEvidenceObject -Argument @{ nEvObjID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfEvidenceObjectProperty {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetEvObjProp.

    .DESCRIPTION
    Get-XwfEvidenceObjectProperty maps one-to-one to the verified X-Ways export
    XWF_GetEvObjProp. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetEvObjProp( HANDLE hEvidence, DWORD nPropType, PVOID lpBuffer );

    Documented parameter names: hEvidence;nPropType;lpBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfEvidenceObjectProperty -Argument @{ hEvidence = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetEvObjProp' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Close-XwfEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CloseEvObj.

    .DESCRIPTION
    Close-XwfEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_CloseEvObj. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    VOID XWF_CloseEvObj( HANDLE hEvidence );

    Documented parameter names: hEvidence
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Close-XwfEvidenceObject -Argument @{ hEvidence = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CloseEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Open-XwfEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_OpenEvObj.

    .DESCRIPTION
    Open-XwfEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_OpenEvObj. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    HANDLE XWF_OpenEvObj( HANDLE hEvidence, DWORD nFlags );

    Documented parameter names: hEvidence;nFlags
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Open-XwfEvidenceObject -Argument @{ hEvidence = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_OpenEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function New-XwfEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CreateEvObj.

    .DESCRIPTION
    New-XwfEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_CreateEvObj. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    HANDLE XWF_CreateEvObj( DWORD nType, LONG nDiskID, LPWSTR lpPath, PVOID
    pReserved );

    Documented parameter names: nType;nDiskID;lpPath;pReserved
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    New-XwfEvidenceObject -Argument @{ nType = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CreateEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfNextEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetNextEvObj.

    .DESCRIPTION
    Get-XwfNextEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_GetNextEvObj. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    HANDLE XWF_GetNextEvObj( HANDLE hPrevEvidence, LPVOID pReserved );

    Documented parameter names: hPrevEvidence;pReserved
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfNextEvidenceObject -Argument @{ hPrevEvidence = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetNextEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfFirstEvidenceObject {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetFirstEvObj.

    .DESCRIPTION
    Get-XwfFirstEvidenceObject maps one-to-one to the verified X-Ways export
    XWF_GetFirstEvObj. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    HANDLE XWF_GetFirstEvObj( LPVOID pReserved );

    Documented parameter names: pReserved
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfFirstEvidenceObject -Argument @{ pReserved = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetFirstEvObj' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfCaseProperty {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetCaseProp.

    .DESCRIPTION
    Get-XwfCaseProperty maps one-to-one to the verified X-Ways export
    XWF_GetCaseProp. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetCaseProp( LPVOID pReserved, LONG nPropType, PVOID pBuffer, LONG
    nBufLen );

    Documented parameter names: pReserved;nPropType;pBuffer;nBufLen
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfCaseProperty -Argument @{ pReserved = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetCaseProp' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function New-XwfContainer {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CreateContainer.

    .DESCRIPTION
    New-XwfContainer maps one-to-one to the verified X-Ways export
    XWF_CreateContainer. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    HANDLE XWF_CreateContainer( LPWSTR lpFileName, DWORD nFlags, LPVOID
    pReserved );

    Documented parameter names: lpFileName;nFlags;pReserved
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    New-XwfContainer -Argument @{ lpFileName = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CreateContainer' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Close-XwfContainer {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CloseContainer.

    .DESCRIPTION
    Close-XwfContainer maps one-to-one to the verified X-Ways export
    XWF_CloseContainer. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_CloseContainer( HANDLE hContainer, LPVOID pReserved );

    Documented parameter names: hContainer;pReserved
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Close-XwfContainer -Argument @{ hContainer = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CloseContainer' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Copy-XwfItemToContainer {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CopyToContainer.

    .DESCRIPTION
    Copy-XwfItemToContainer maps one-to-one to the verified X-Ways export
    XWF_CopyToContainer. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_CopyToContainer( HANDLE hContainer, HANDLE hItem, DWORD nFlags,
    DWORD nMode, INT64 nStartOfs, INT64 nEndOfs, LPVOID pReserved );

    Documented parameter names: hContainer;hItem;nFlags;nMode;nStartOfs;nEndOfs;pReserved
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Copy-XwfItemToContainer -Argument @{ hContainer = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CopyToContainer' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfRasterImage {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetRasterImage.

    .DESCRIPTION
    Get-XwfRasterImage maps one-to-one to the verified X-Ways export
    XWF_GetRasterImage. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPVOID XWF_GetRasterImage( struct RasterImageInfo* pRIInfo );

    Documented parameter names: pRIInfo
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfRasterImage -Argument @{ pRIInfo = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetRasterImage' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfText {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetText.

    .DESCRIPTION
    Get-XwfText maps one-to-one to the verified X-Ways export XWF_GetText. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LPVOID XWF_GetText( HANDLE hItem, DWORD nFlags, PINTEGER lpnResult, PDWORD
    lpnBufUsedSize, PDWORD lpnBufAllocSize );

    Documented parameter names: hItem;nFlags;lpnResult;lpnBufUsedSize;lpnBufAllocSize
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfText -Argument @{ hItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetText' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Initialize-XwfTextAccess {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_PrepareTextAccess.

    .DESCRIPTION
    Initialize-XwfTextAccess maps one-to-one to the verified X-Ways export
    XWF_PrepareTextAccess. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_PrepareTextAccess( DWORD nFlags, LPSTR lpLangs );

    Documented parameter names: nFlags;lpLangs
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Initialize-XwfTextAccess -Argument @{ nFlags = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_PrepareTextAccess' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfExtendedMetadata {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetMetadataEx.

    .DESCRIPTION
    Get-XwfExtendedMetadata maps one-to-one to the verified X-Ways export
    XWF_GetMetadataEx. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPVOID XWF_GetMetadataEx( HANDLE hItem, PDWORD lpnFlags );

    Documented parameter names: hItem;lpnFlags
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfExtendedMetadata -Argument @{ hItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetMetadataEx' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfMetadata {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetMetadata.

    .DESCRIPTION
    Get-XwfMetadata maps one-to-one to the verified X-Ways export
    XWF_GetMetadata. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPWSTR XWF_GetMetadata( LONG nItemID, HANDLE hItem );

    Documented parameter names: nItemID;hItem
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfMetadata -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetMetadata' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfCellText {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetCellText.

    .DESCRIPTION
    Get-XwfCellText maps one-to-one to the verified X-Ways export
    XWF_GetCellText. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_GetCellText( LONG nItemID , LPVOID lpPointer, DWORD nFlags, WORD
    nColIndex, LPWSTR lpBuffer, DWORD nBufferLen );

    Documented parameter names: nItemID;lpPointer;nFlags;nColIndex;lpBuffer;nBufferLen
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfCellText -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetCellText' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfHashValue {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetHashValue.

    .DESCRIPTION
    Set-XwfHashValue maps one-to-one to the verified X-Ways export
    XWF_SetHashValue. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetHashValue( LONG nItemID, LPVOID lpHash, DWORD nParam );

    Documented parameter names: nItemID;lpHash;nParam
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfHashValue -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetHashValue' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfHashValue {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetHashValue.

    .DESCRIPTION
    Get-XwfHashValue maps one-to-one to the verified X-Ways export
    XWF_GetHashValue. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_GetHashValue( LONG nItemID , LPVOID lpBuffer );

    Documented parameter names: nItemID;lpBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfHashValue -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetHashValue' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Add-XwfExtractedMetadata {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_AddExtractedMetadata.

    .DESCRIPTION
    Add-XwfExtractedMetadata maps one-to-one to the verified X-Ways export
    XWF_AddExtractedMetadata. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_AddExtractedMetadata( LONG nItemID, LPWSTR lpComment, DWORD
    nFlagsHowToAdd );

    Documented parameter names: nItemID;lpComment;nFlagsHowToAdd
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Add-XwfExtractedMetadata -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_AddExtractedMetadata' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfExtractedMetadata {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetExtractedMetadata.

    .DESCRIPTION
    Get-XwfExtractedMetadata maps one-to-one to the verified X-Ways export
    XWF_GetExtractedMetadata. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPWSTR XWF_GetExtractedMetadata( LONG nItemID );

    Documented parameter names: nItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfExtractedMetadata -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetExtractedMetadata' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Add-XwfComment {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_AddComment.

    .DESCRIPTION
    Add-XwfComment maps one-to-one to the verified X-Ways export XWF_AddComment.
    It does not load or call the X-Ways executable. It validates arguments
    against the local catalog and emits an xwf-api-bridge-request/v1 object,
    optionally appending that request to a JSONL outbox for an in-process
    X-Tension bridge.

    Native signature:
    BOOL XWF_AddComment( LONG nItemID, LPWSTR lpComment, DWORD nFlagsHowToAdd );

    Documented parameter names: nItemID;lpComment;nFlagsHowToAdd
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Add-XwfComment -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_AddComment' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfComment {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetComment.

    .DESCRIPTION
    Get-XwfComment maps one-to-one to the verified X-Ways export XWF_GetComment.
    It does not load or call the X-Ways executable. It validates arguments
    against the local catalog and emits an xwf-api-bridge-request/v1 object,
    optionally appending that request to a JSONL outbox for an in-process
    X-Tension bridge.

    Native signature:
    LPWSTR XWF_GetComment( LONG nItemID );

    Documented parameter names: nItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfComment -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetComment' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Add-XwfReportTableEntry {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_AddToReportTable.

    .DESCRIPTION
    Add-XwfReportTableEntry maps one-to-one to the verified X-Ways export
    XWF_AddToReportTable. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    XWF_AddToReportTable(...)

    Documented parameter names: No documented parameters captured.
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Add-XwfReportTableEntry -Argument @{} -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_AddToReportTable' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemLabel {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Label.

    .DESCRIPTION
    Set-XwfItemLabel maps one-to-one to the verified X-Ways export XWF_Label. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_Label( LONG nItemID, LPWSTR lpLabelName, DWORD nFlags );

    Documented parameter names: nItemID;lpLabelName;nFlags
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemLabel -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Label' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfReportTableAssociation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetReportTableAssocs.

    .DESCRIPTION
    Get-XwfReportTableAssociation maps one-to-one to the verified X-Ways export
    XWF_GetReportTableAssocs. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    XWF_GetReportTableAssocs(...)

    Documented parameter names: No documented parameters captured.
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfReportTableAssociation -Argument @{} -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetReportTableAssocs' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfLabels {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetLabels.

    .DESCRIPTION
    Get-XwfLabels maps one-to-one to the verified X-Ways export XWF_GetLabels.
    It does not load or call the X-Ways executable. It validates arguments
    against the local catalog and emits an xwf-api-bridge-request/v1 object,
    optionally appending that request to a JSONL outbox for an in-process
    X-Tension bridge.

    Native signature:
    INT64 XWF_GetLabels( LONG nItemID , LPWSTR lpBuffer, DWORD
    nBufLenAndMatchType );

    Documented parameter names: nItemID;lpBuffer;nBufLenAndMatchType
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfLabels -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetLabels' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfHashSetAssociation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetHashSetAssocs.

    .DESCRIPTION
    Get-XwfHashSetAssociation maps one-to-one to the verified X-Ways export
    XWF_GetHashSetAssocs. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_GetHashSetAssocs( LONG nItemID , LPWSTR lpBuffer, LONG nBufferLen
    );

    Documented parameter names: nItemID;lpBuffer;nBufferLen
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfHashSetAssociation -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetHashSetAssocs' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemParent {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetItemParent.

    .DESCRIPTION
    Set-XwfItemParent maps one-to-one to the verified X-Ways export
    XWF_SetItemParent. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetItemParent( LONG nChildItemID, LONG nParentItemID );

    Documented parameter names: nChildItemID;nParentItemID
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemParent -Argument @{ nChildItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetItemParent' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemParent {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemParent.

    .DESCRIPTION
    Get-XwfItemParent maps one-to-one to the verified X-Ways export
    XWF_GetItemParent. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_GetItemParent( LONG nItemID );

    Documented parameter names: nItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemParent -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemParent' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemType {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetItemType.

    .DESCRIPTION
    Set-XwfItemType maps one-to-one to the verified X-Ways export
    XWF_SetItemType. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetItemType( LONG nItemID , LPWSTR lpTypeDescr, LONG nTypeStatus );

    Documented parameter names: nItemID;lpTypeDescr;nTypeStatus
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemType -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetItemType' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemType {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemType.

    .DESCRIPTION
    Get-XwfItemType maps one-to-one to the verified X-Ways export
    XWF_GetItemType. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_GetItemType( LONG nItemID , LPWSTR lpTypeDescr, DWORD
    nBufferLenAndFlags );

    Documented parameter names: nItemID;lpTypeDescr;nBufferLenAndFlags
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemType -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemType' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemInformation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetItemInformation.

    .DESCRIPTION
    Set-XwfItemInformation maps one-to-one to the verified X-Ways export
    XWF_SetItemInformation. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetItemInformation( LONG nItemID, LONG nInfoType, INT64 nInfoValue
    );

    Documented parameter names: nItemID;nInfoType;nInfoValue
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemInformation -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetItemInformation' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemInformation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemInformation.

    .DESCRIPTION
    Get-XwfItemInformation maps one-to-one to the verified X-Ways export
    XWF_GetItemInformation. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetItemInformation( LONG nItemID, LONG nInfoType, LPBOOL
    lpSuccess, );

    Documented parameter names: nItemID;nInfoType;lpSuccess
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemInformation -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemInformation' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemOffset {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetItemOfs.

    .DESCRIPTION
    Set-XwfItemOffset maps one-to-one to the verified X-Ways export
    XWF_SetItemOfs. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    BOOL XWF_SetItemOfs( LONG nItemID, INT64 nDefOfs, INT64 nStartSector );

    Documented parameter names: nItemID;nDefOfs;nStartSector
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemOffset -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetItemOfs' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemOffset {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemOfs.

    .DESCRIPTION
    Get-XwfItemOffset maps one-to-one to the verified X-Ways export
    XWF_GetItemOfs. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    VOID XWF_GetItemOfs( LONG nItemID, LPINT64 lpDefOfs, LPINT64 lpStartSector
    );

    Documented parameter names: nItemID;lpDefOfs;lpStartSector
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemOffset -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemOfs' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfItemSize {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetItemSize.

    .DESCRIPTION
    Set-XwfItemSize maps one-to-one to the verified X-Ways export
    XWF_SetItemSize. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetItemSize( LONG nItemID, INT64 nSize );

    Documented parameter names: nItemID;nSize
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfItemSize -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetItemSize' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemSize {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemSize.

    .DESCRIPTION
    Get-XwfItemSize maps one-to-one to the verified X-Ways export
    XWF_GetItemSize. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetItemSize( LONG nItemID );

    Documented parameter names: nItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemSize -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemSize' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemName {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemName.

    .DESCRIPTION
    Get-XwfItemName maps one-to-one to the verified X-Ways export
    XWF_GetItemName. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LPWSTR XWF_GetItemName( DWORD nItemID );

    Documented parameter names: nItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemName -Argument @{ nItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemName' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Dismount-XwfVolume {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Unmount.

    .DESCRIPTION
    Dismount-XwfVolume maps one-to-one to the verified X-Ways export
    XWF_Unmount. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    BOOL XWF_Unmount( LPWSTR lpMountPath );

    Documented parameter names: lpMountPath
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Dismount-XwfVolume -Argument @{ lpMountPath = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Unmount' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Mount-XwfVolume {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Mount.

    .DESCRIPTION
    Mount-XwfVolume maps one-to-one to the verified X-Ways export XWF_Mount. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_Mount( LONG nDirID, LPWSTR lpMountPath, LPVOID lpReserved );

    Documented parameter names: nDirID;lpMountPath;lpReserved
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Mount-XwfVolume -Argument @{ nDirID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Mount' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Find-XwfItem {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_FindItem1.

    .DESCRIPTION
    Find-XwfItem maps one-to-one to the verified X-Ways export XWF_FindItem1. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_FindItem1( LONG nParentItemID, LPWSTR lpName, DWORD nFlags, LONG
    nSearchStartItemID );

    Documented parameter names: nParentItemID;lpName;nFlags;nSearchStartItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Find-XwfItem -Argument @{ nParentItemID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_FindItem1' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function New-XwfFile {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CreateFile.

    .DESCRIPTION
    New-XwfFile maps one-to-one to the verified X-Ways export XWF_CreateFile. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_CreateFile( LPWSTR pName, DWORD nCreationFlags, LONG nParentItemID,
    PVOID pSourceInfo );

    Documented parameter names: pName;nCreationFlags;nParentItemID;pSourceInfo
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    New-XwfFile -Argument @{ pName = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CreateFile' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function New-XwfItem {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_CreateItem.

    .DESCRIPTION
    New-XwfItem maps one-to-one to the verified X-Ways export XWF_CreateItem. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    LONG XWF_CreateItem( LPWSTR lpName, DWORD nCreationFlags );

    Documented parameter names: lpName;nCreationFlags
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    New-XwfItem -Argument @{ lpName = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_CreateItem' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfFileCount {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetFileCount.

    .DESCRIPTION
    Get-XwfFileCount maps one-to-one to the verified X-Ways export
    XWF_GetFileCount. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_GetFileCount( LONG nDirID );

    Documented parameter names: nDirID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfFileCount -Argument @{ nDirID = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetFileCount' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfItemCount {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetItemCount.

    .DESCRIPTION
    Get-XwfItemCount maps one-to-one to the verified X-Ways export
    XWF_GetItemCount. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_GetItemCount( LPVOID pTarget );

    Documented parameter names: pTarget
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfItemCount -Argument @{ pTarget = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetItemCount' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfVolumeSnapshotProperty {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetVSProp.

    .DESCRIPTION
    Get-XwfVolumeSnapshotProperty maps one-to-one to the verified X-Ways export
    XWF_GetVSProp. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    INT64 XWF_GetVSProp( LONG nPropType, PVOID pBuffer );

    Documented parameter names: nPropType;pBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfVolumeSnapshotProperty -Argument @{ nPropType = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetVSProp' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Select-XwfVolumeSnapshot {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SelectVolumeSnapshot.

    .DESCRIPTION
    Select-XwfVolumeSnapshot maps one-to-one to the verified X-Ways export
    XWF_SelectVolumeSnapshot. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    LONG XWF_SelectVolumeSnapshot( HANDLE hVolume );

    Documented parameter names: hVolume
    Risk level: mutating-or-stateful

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Select-XwfVolumeSnapshot -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SelectVolumeSnapshot' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Invoke-XwfSectorIo {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SectorIO.

    .DESCRIPTION
    Invoke-XwfSectorIo maps one-to-one to the verified X-Ways export
    XWF_SectorIO. It does not load or call the X-Ways executable. It validates
    arguments against the local catalog and emits an xwf-api-bridge-request/v1
    object, optionally appending that request to a JSONL outbox for an in-
    process X-Tension bridge.

    Native signature:
    DWORD XWF_SectorIO( LONG nDrive , INT64 nSector , DWORD nCount, LPVOID
    lpBuffer , LPDWORD nFlags );

    Documented parameter names: nDrive;nSector;nCount;lpBuffer;nFlags
    Risk level: content-and-state

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Invoke-XwfSectorIo -Argument @{ nDrive = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SectorIO' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Read-XwfContent {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Read.

    .DESCRIPTION
    Read-XwfContent maps one-to-one to the verified X-Ways export XWF_Read. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    DWORD XWF_Read( HANDLE hVolumeOrItem , INT64 nOffset , LPVOID lpBuffer ,
    DWORD nNumberOfBytesToRead, );

    Documented parameter names: hVolumeOrItem;nOffset;lpBuffer;nNumberOfBytesToRead
    Risk level: content-access

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Read-XwfContent -Argument @{ hVolumeOrItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Read' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Close-XwfContext {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_Close.

    .DESCRIPTION
    Close-XwfContext maps one-to-one to the verified X-Ways export XWF_Close. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    VOID XWF_Close( HANDLE hVolumeOrItem );

    Documented parameter names: hVolumeOrItem
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Close-XwfContext -Argument @{ hVolumeOrItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_Close' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Open-XwfItem {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_OpenItem.

    .DESCRIPTION
    Open-XwfItem maps one-to-one to the verified X-Ways export XWF_OpenItem. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    Flags that are returned for XWF_ITEM_INFO_FLAGS: 0x00000001: is a directory
    0x00000002: has child objects (for files only) 0x00000004: has
    subdirectories (for directories only) 0x00000008: is a virtual item
    0x00000010: hidden by examiner 0x00000020: tagged 0x00000040: tagged
    partially 0x00000080: viewed by examiner 0x00000100: file system timestamps
    not in UTC 0x00000200: internal creation timestamp not in UTC 0x00000400:
    FAT timestamps 0x00000800: originates from NTFS 0x00001000: Unix permissions
    instead of Windows attributes 0x00002000: has examiner comment 0x00004000:
    has extracted metadata 0x00008000: file contents totally unknown 0x00010000:
    file contents partially unknown 0x00020000: reserved 0x00040000: hash 1
    already computed 0x00080000: has duplicates 0x00100000: hash 2 already
    computed (since v18.0) 0x00200000: categorized as known
    good/irrelevant/ignorable 0x00400000: categorized as bad/relevant/notable
    0x00600000: uncategorized, but known (both flags!, v18.9+) 0x00800000: if in
    NTFS: found in volume shadow copy 0x01000000: deleted files with known
    original contents 0x02000000: file format consistency OK 0x04000000: file
    format consistency not OK 0x10000000: file archive already explored (v17.6+)
    0x20000000: e-mail archive processed (v17.6+) 0x40000000: embedded data
    already uncovered, incl. still images from videos (v17.6+) 0x80000000:
    metadata extraction already applied (v17.6+) 0x100000000: file embedded in
    other file linearly (v17.7+)* 0x200000000: file whose contents is stored
    externally (v17.7+)* 0x400000000: alternative data /a via XWF_OpenItem
    (v18.9+)*

    Documented parameter names: No documented parameters captured.
    Risk level: content-access

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Open-XwfItem -Argument @{} -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_OpenItem' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfSectorContents {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetSectorContents.

    .DESCRIPTION
    Get-XwfSectorContents maps one-to-one to the verified X-Ways export
    XWF_GetSectorContents. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_GetSectorContents( HANDLE hVolume, INT64 nSectorNo, LPWSTR lpDescr,
    LPLONG lpItemID );

    Documented parameter names: hVolume;nSectorNo;lpDescr;lpItemID
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfSectorContents -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetSectorContents' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Set-XwfBlock {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_SetBlock.

    .DESCRIPTION
    Set-XwfBlock maps one-to-one to the verified X-Ways export XWF_SetBlock. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_SetBlock( HANDLE hVolume, INT64 nStartOfs, INT64 nEndOfs );

    Documented parameter names: hVolume;nStartOfs;nEndOfs
    Risk level: content-and-state

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Set-XwfBlock -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_SetBlock' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfBlock {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetBlock.

    .DESCRIPTION
    Get-XwfBlock maps one-to-one to the verified X-Ways export XWF_GetBlock. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    BOOL XWF_GetBlock( HANDLE hVolume, PINT64 lpStartOfs, PINT64 lpEndOfs );

    Documented parameter names: hVolume;lpStartOfs;lpEndOfs
    Risk level: content-access

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfBlock -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetBlock' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfVolumeInformation {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetVolumeInformation.

    .DESCRIPTION
    Get-XwfVolumeInformation maps one-to-one to the verified X-Ways export
    XWF_GetVolumeInformation. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    VOID XWF_GetVolumeInformation( HANDLE hVolume, LPLONG lpFileSystem, LPDWORD
    lpBytesPerSector, LPDWORD lpSectorsPerCluster, PINT64 lpClusterCount, PINT64
    lpFirstClusterSectorNo );

    Documented parameter names: hVolume;lpFileSystem;lpBytesPerSector;lpSectorsPerCluster;lpClusterCount;lpFirstClusterSectorNo
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfVolumeInformation -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetVolumeInformation' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfVolumeName {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetVolumeName.

    .DESCRIPTION
    Get-XwfVolumeName maps one-to-one to the verified X-Ways export
    XWF_GetVolumeName. It does not load or call the X-Ways executable. It
    validates arguments against the local catalog and emits an xwf-api-bridge-
    request/v1 object, optionally appending that request to a JSONL outbox for
    an in-process X-Tension bridge.

    Native signature:
    VOID XWF_GetVolumeName( HANDLE hVolume, LPWSTR lpBuffer, DWORD nType );

    Documented parameter names: hVolume;lpBuffer;nType
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfVolumeName -Argument @{ hVolume = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetVolumeName' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfProperty {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetProp.

    .DESCRIPTION
    Get-XwfProperty maps one-to-one to the verified X-Ways export XWF_GetProp.
    It does not load or call the X-Ways executable. It validates arguments
    against the local catalog and emits an xwf-api-bridge-request/v1 object,
    optionally appending that request to a JSONL outbox for an in-process
    X-Tension bridge.

    Native signature:
    INT64 XWF_GetProp( HANDLE hVolumeOrItem, DWORD nPropType, PVOID lpBuffer );

    Documented parameter names: hVolumeOrItem;nPropType;lpBuffer
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfProperty -Argument @{ hVolumeOrItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetProp' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}

function Get-XwfSize {
    <#
    .SYNOPSIS
    Creates a validated X-Tension bridge request for XWF_GetSize.

    .DESCRIPTION
    Get-XwfSize maps one-to-one to the verified X-Ways export XWF_GetSize. It
    does not load or call the X-Ways executable. It validates arguments against
    the local catalog and emits an xwf-api-bridge-request/v1 object, optionally
    appending that request to a JSONL outbox for an in-process X-Tension bridge.

    Native signature:
    INT64 XWF_GetSize( HANDLE hVolumeOrItem, LPVOID lpOptional );

    Documented parameter names: hVolumeOrItem;lpOptional
    Risk level: metadata-or-control

    .PARAMETER Argument
    Hashtable of argument names and values for the X-Tension bridge runner.

    .PARAMETER OutboxPath
    Optional JSONL outbox path. If omitted, the request object is returned only.

    .PARAMETER RequestId
    Stable request id. Defaults to a new GUID.

    .PARAMETER CaseId
    Optional local case/run identifier for audit logs.

    .PARAMETER Purpose
    Short reason the agent is requesting the API call.

    .PARAMETER AllowMutating
    Required when the catalog marks the API as mutating or state-changing.

    .PARAMETER AllowContentAccess
    Required when the catalog marks the API as content-reading.

    .PARAMETER PassThru
    Return the request object after writing to -OutboxPath.

    .EXAMPLE
    Get-XwfSize -Argument @{ hVolumeOrItem = 0 } -Purpose 'Plan bridge call'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [hashtable]$Argument = @{},

        [string]$OutboxPath = '',

        [string]$RequestId = ([guid]::NewGuid().ToString()),

        [string]$CaseId = '',

        [string]$Purpose = '',

        [switch]$AllowMutating,

        [switch]$AllowContentAccess,

        [switch]$PassThru
    )

    Invoke-XwfApiFunction `
        -ApiName 'XWF_GetSize' `
        -Argument $Argument `
        -OutboxPath $OutboxPath `
        -RequestId $RequestId `
        -CaseId $CaseId `
        -Purpose $Purpose `
        -AllowMutating:$AllowMutating `
        -AllowContentAccess:$AllowContentAccess `
        -PassThru:$PassThru
}
