<#
.SYNOPSIS
    Edits a catalog's name, description, or enabled settings.

.DESCRIPTION
    Portal equivalent: Catalog > Overview > Edit > Save.
    Graph API:         PATCH /identityGovernance/entitlementManagement/catalogs/{id}

    Only the properties you pass are sent, so everything else stays as it is.

.PARAMETER NewDisplayName
    New catalog name.

.PARAMETER Description
    New description.

.PARAMETER State
    'published' (portal: Enabled for users to request = Yes) or 'unpublished'.

.PARAMETER ExternallyVisible
    Portal: Enabled for external users to request.

.EXAMPLE
    ./scripts/Update-LabCatalog.ps1 -CatalogName 'IAM-Lab-Catalog' -Description 'New description' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory, ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(Mandatory, ParameterSetName = 'ById')][string]$CatalogId,
    [string]$NewDisplayName,
    [string]$Description,
    [ValidateSet('published', 'unpublished')][string]$State,
    [bool]$ExternallyVisible
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

$body = @{}
if ($PSBoundParameters.ContainsKey('NewDisplayName'))    { $body['displayName']         = $NewDisplayName }
if ($PSBoundParameters.ContainsKey('Description'))       { $body['description']         = $Description }
if ($PSBoundParameters.ContainsKey('State'))             { $body['state']               = $State }
if ($PSBoundParameters.ContainsKey('ExternallyVisible')) { $body['isExternallyVisible'] = $ExternallyVisible }

if ($body.Count -eq 0) {
    throw 'Nothing to update. Pass -NewDisplayName, -Description, -State, or -ExternallyVisible.'
}

$catalog = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId

if ($PSCmdlet.ShouldProcess($catalog.DisplayName, "Update catalog ($($body.Keys -join ', '))")) {
    Update-MgEntitlementManagementCatalog -AccessPackageCatalogId $catalog.Id -BodyParameter $body
    Write-Host "Updated catalog '$($catalog.DisplayName)'" -ForegroundColor Green
}
