<#
.SYNOPSIS
    Shows a catalog with its resources and catalog-scoped role assignments, or lists all catalogs.

.DESCRIPTION
    Read-only. Use it to verify the result of the other scripts (or of the portal steps).
    Graph API: GET /identityGovernance/entitlementManagement/catalogs
               GET /roleManagement/entitlementManagement/roleAssignments

.EXAMPLE
    ./scripts/Get-LabCatalog.ps1

.EXAMPLE
    ./scripts/Get-LabCatalog.ps1 -CatalogName 'IAM-Lab-Catalog'
#>
[CmdletBinding(DefaultParameterSetName = 'List')]
param(
    [Parameter(ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(ParameterSetName = 'ById')][string]$CatalogId
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

if ($PSCmdlet.ParameterSetName -eq 'List') {
    Get-MgEntitlementManagementCatalog -All |
        Select-Object DisplayName, State, IsExternallyVisible, CatalogType, Id |
        Format-Table -AutoSize
    return
}

$catalog = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId

Write-Host "`n== Catalog ==" -ForegroundColor Cyan
$catalog | Select-Object DisplayName, Description, State, IsExternallyVisible, CreatedDateTime, Id | Format-List

Write-Host "== Resources ==" -ForegroundColor Cyan
$resources = @(Get-CatalogResources -CatalogId $catalog.Id)
if ($resources.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $resources | Select-Object DisplayName, ResourceType, OriginSystem, OriginId | Format-Table -AutoSize
}

Write-Host "== Roles and administrators ==" -ForegroundColor Cyan
$assignments = @(Get-CatalogRoleAssignments -CatalogId $catalog.Id)
if ($assignments.Count -eq 0) {
    Write-Host '(none)'
}
else {
    $assignments | ForEach-Object {
        $displayName = '(unresolved)'
        try {
            $obj = Get-MgDirectoryObject -DirectoryObjectId $_.PrincipalId -ErrorAction Stop
            if ($obj.AdditionalProperties.ContainsKey('displayName')) { $displayName = $obj.AdditionalProperties['displayName'] }
        }
        catch { }

        [pscustomobject]@{
            Role        = Get-CatalogRoleName -RoleDefinitionId $_.RoleDefinitionId
            Principal   = $displayName
            PrincipalId = $_.PrincipalId
        }
    } | Format-Table -AutoSize
}
