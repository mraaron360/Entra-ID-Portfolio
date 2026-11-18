<#
.SYNOPSIS
    Removes a resource from a catalog.

.DESCRIPTION
    Portal equivalent: Catalog > Resources > select the resource > Remove.
    Graph API:         POST /identityGovernance/entitlementManagement/resourceRequests
                       (requestType = adminRemove)

    A resource can only be removed if no access package in the catalog uses it.
    This removes the resource from the catalog only; the group or application itself is not touched.

.PARAMETER ResourceName
    Display name of the resource as shown in the catalog.

.EXAMPLE
    ./scripts/Remove-CatalogResource.ps1 -CatalogName 'IAM-Lab-Catalog' -ResourceName 'Developers' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium', DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory, ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(Mandatory, ParameterSetName = 'ById')][string]$CatalogId,
    [Parameter(Mandatory)][string]$ResourceName
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

$catalog = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId
$found   = @(Get-CatalogResources -CatalogId $catalog.Id | Where-Object { $_.DisplayName -eq $ResourceName })

if ($found.Count -eq 0) { throw "No resource named '$ResourceName' in catalog '$($catalog.DisplayName)'." }
if ($found.Count -gt 1) { throw "Resource name '$ResourceName' matches $($found.Count) resources in the catalog." }

$request = @{
    requestType = 'adminRemove'
    resource    = @{ id = $found[0].Id }
    catalog     = @{ id = $catalog.Id }
}

if ($PSCmdlet.ShouldProcess($catalog.DisplayName, "Remove resource '$ResourceName' from catalog")) {
    $null = New-MgEntitlementManagementResourceRequest -BodyParameter $request
    Write-Host "Requested removal of '$ResourceName' from '$($catalog.DisplayName)'" -ForegroundColor Green
}
