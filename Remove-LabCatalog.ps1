<#
.SYNOPSIS
    Deletes a catalog.

.DESCRIPTION
    Portal equivalent: Catalog > Overview > Delete > Yes.
    Graph API:         DELETE /identityGovernance/entitlementManagement/catalogs/{id}

    A catalog can only be deleted when it contains no access packages. Resources and
    role assignments scoped to the catalog go away with it; the underlying groups and
    applications are not touched. This is destructive, so confirmation is requested by
    default. Run with -WhatIf first.

.EXAMPLE
    ./scripts/Remove-LabCatalog.ps1 -CatalogName 'IAM-Lab-Catalog' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory, ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(Mandatory, ParameterSetName = 'ById')][string]$CatalogId
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

$catalog = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId

if ($catalog.CatalogType -eq 'serviceDefault') {
    throw "'$($catalog.DisplayName)' is the built-in catalog and cannot be deleted."
}

# Friendly pre-check. If the expand is not supported the API still enforces the rule.
$packageCount = $null
try {
    $withPackages = Get-MgEntitlementManagementCatalog -AccessPackageCatalogId $catalog.Id -ExpandProperty accessPackages -ErrorAction Stop
    $packageCount = @($withPackages.AccessPackages | Where-Object { $null -ne $_ }).Count
}
catch {
    Write-Verbose "Could not pre-check access packages: $($_.Exception.Message)"
}

if ($packageCount -gt 0) {
    throw "Catalog '$($catalog.DisplayName)' still contains $packageCount access package(s). Remove them first."
}

if ($PSCmdlet.ShouldProcess($catalog.DisplayName, 'Delete entitlement management catalog')) {
    Remove-MgEntitlementManagementCatalog -AccessPackageCatalogId $catalog.Id
    Write-Host "Deleted catalog '$($catalog.DisplayName)'" -ForegroundColor Yellow
}
