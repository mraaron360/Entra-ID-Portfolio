<#
.SYNOPSIS
    Creates a catalog in Microsoft Entra entitlement management.

.DESCRIPTION
    Portal equivalent: ID Governance > Catalogs > New catalog.
    Graph API:         POST /identityGovernance/entitlementManagement/catalogs

    The script is idempotent by name: if a catalog with the same display name already exists,
    it is returned and nothing is created.

.PARAMETER DisplayName
    Unique catalog name. Users see it in access package details.

.PARAMETER Description
    Catalog description. Users see it in access package details.

.PARAMETER Enabled
    Portal: "Enabled for users to request". $true publishes the catalog (state = published).

.PARAMETER ExternallyVisible
    Portal: "Enabled for external users to request".

.EXAMPLE
    ./scripts/New-LabCatalog.ps1 -DisplayName 'IAM-Lab-Catalog' -Description 'Lab catalog' -WhatIf

.EXAMPLE
    ./scripts/New-LabCatalog.ps1 -DisplayName 'IAM-Lab-Catalog' -Description 'Lab catalog'
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$DisplayName,
    [Parameter(Mandatory)][string]$Description,
    [bool]$Enabled = $true,
    [bool]$ExternallyVisible = $false
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

$existing = Get-CatalogByName -Name $DisplayName -AllowMissing
if ($existing) {
    Write-Warning "Catalog '$DisplayName' already exists (Id $($existing.Id)). Nothing to create."
    return $existing
}

$state = 'unpublished'
if ($Enabled) { $state = 'published' }

$body = @{
    displayName         = $DisplayName
    description         = $Description
    state               = $state
    isExternallyVisible = $ExternallyVisible
}

if ($PSCmdlet.ShouldProcess($DisplayName, 'Create entitlement management catalog')) {
    $catalog = New-MgEntitlementManagementCatalog -BodyParameter $body
    Write-Host "Created catalog '$($catalog.DisplayName)' (Id $($catalog.Id))" -ForegroundColor Green
    return $catalog
}
