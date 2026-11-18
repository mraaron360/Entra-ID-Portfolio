<#
.SYNOPSIS
    Shared helpers for the entitlement management catalog scripts.

.DESCRIPTION
    Dot-source this file from the other scripts:

        . "$PSScriptRoot/Common.ps1"

    Nothing in here talks to the tenant on its own; every function expects an
    existing Microsoft Graph PowerShell session (see Connect-EntitlementManagement.ps1).
#>

# Built-in entitlement management catalog role definition IDs.
# These are constants, identical in every tenant.
$CatalogRoleIds = @{
    Owner                = 'ae79f266-94d4-4dab-b730-feca7e132178'
    Reader               = '44272f93-9762-48e8-af59-1b5351b1d6b3'
    AccessPackageManager = '7f480852-ebdc-47d4-87de-0d8498384a83'
}

function Assert-GraphContext {
    <#
    .SYNOPSIS
        Fails fast if there is no Graph session or a required delegated scope is missing.
    #>
    [CmdletBinding()]
    param(
        [string[]]$RequiredScopes = @('EntitlementManagement.ReadWrite.All')
    )

    $ctx = Get-MgContext
    if (-not $ctx) {
        throw 'Not connected to Microsoft Graph. Run ./scripts/Connect-EntitlementManagement.ps1 first.'
    }

    $missing = @($RequiredScopes | Where-Object { $_ -notin $ctx.Scopes })
    if ($missing.Count -gt 0) {
        throw "The current Graph session is missing scope(s): $($missing -join ', '). Reconnect with Connect-EntitlementManagement.ps1 -Scopes ..."
    }
}

function ConvertTo-ODataString {
    <# Escapes single quotes so a value can be embedded in an OData $filter string. #>
    param([Parameter(Mandatory)][string]$Value)
    $Value.Replace("'", "''")
}

function Get-CatalogByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [switch]$AllowMissing
    )

    $filter = "displayName eq '$(ConvertTo-ODataString $Name)'"
    $found  = @(Get-MgEntitlementManagementCatalog -Filter $filter -All)

    if ($found.Count -eq 0) {
        if ($AllowMissing) { return $null }
        throw "No catalog named '$Name' was found."
    }
    if ($found.Count -gt 1) {
        throw "More than one catalog is named '$Name'. Use -CatalogId instead."
    }
    return $found[0]
}

function Resolve-Catalog {
    <# Returns a catalog object from either a display name or an object ID. #>
    [CmdletBinding()]
    param(
        [string]$CatalogName,
        [string]$CatalogId
    )

    if ($CatalogId)   { return Get-MgEntitlementManagementCatalog -AccessPackageCatalogId $CatalogId }
    if ($CatalogName) { return Get-CatalogByName -Name $CatalogName }
    throw 'Provide -CatalogName or -CatalogId.'
}

function Get-CatalogResources {
    <# Returns the resources registered in a catalog (empty array when there are none). #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$CatalogId)

    $catalog = Get-MgEntitlementManagementCatalog -AccessPackageCatalogId $CatalogId -ExpandProperty resources
    return @($catalog.Resources | Where-Object { $null -ne $_ })
}

function Get-CatalogRoleAssignments {
    <# Returns the catalog-scoped role assignments (owners, readers, access package managers). #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$CatalogId)

    $scope = "/AccessPackageCatalog/$CatalogId"

    try {
        $assignments = @(Get-MgRoleManagementEntitlementManagementRoleAssignment `
                -Filter "appScopeId eq '$scope'" -All -ErrorAction Stop)
    }
    catch {
        Write-Verbose "Server-side filter on appScopeId failed ($($_.Exception.Message)); filtering client-side."
        $assignments = @(Get-MgRoleManagementEntitlementManagementRoleAssignment -All |
                Where-Object { $_.AppScopeId -eq $scope })
    }

    return @($assignments | Where-Object { $null -ne $_ })
}

function Get-CatalogRoleName {
    <# Maps a role definition ID back to a friendly name. #>
    param([Parameter(Mandatory)][string]$RoleDefinitionId)

    $match = $CatalogRoleIds.GetEnumerator() | Where-Object { $_.Value -eq $RoleDefinitionId } | Select-Object -First 1
    if ($match) { return $match.Key }
    return $RoleDefinitionId
}
