<#
.SYNOPSIS
    Adds groups and/or enterprise applications to a catalog as resources.

.DESCRIPTION
    Portal equivalent: Catalog > Resources > Add resources > Groups and Teams / Applications.
    Graph API:         POST /identityGovernance/entitlementManagement/resourceRequests
                       (requestType = adminAdd)

    Notes from the Microsoft documentation:
      * Groups must be cloud-created Microsoft 365 groups or cloud-created security groups.
        Groups synced from on-premises Active Directory cannot be added.
      * Applications are Microsoft Entra enterprise applications (service principals).
      * The caller needs a suitable Entra role or must own the resource, in addition to the
        entitlement management permission.

    Resources that are already in the catalog are skipped, so the script is safe to re-run.

.PARAMETER CatalogName
    Display name of the target catalog.

.PARAMETER CatalogId
    Object ID of the target catalog (use instead of -CatalogName).

.PARAMETER GroupName
    One or more group display names. Each name must match exactly one group.

.PARAMETER ApplicationName
    One or more enterprise application (service principal) display names.

.EXAMPLE
    ./scripts/Add-CatalogResource.ps1 -CatalogName 'IAM-Lab-Catalog' -GroupName 'Application Team','Developers' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory, ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(Mandatory, ParameterSetName = 'ById')][string]$CatalogId,
    [string[]]$GroupName = @(),
    [string[]]$ApplicationName = @()
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

if ($GroupName.Count -eq 0 -and $ApplicationName.Count -eq 0) {
    throw 'Specify at least one -GroupName or -ApplicationName.'
}

$catalog         = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId
$existing        = @(Get-CatalogResources -CatalogId $catalog.Id)
$existingOrigins = @($existing | ForEach-Object { $_.OriginId })

# Resolve every name first so a typo fails before anything is changed.
$targets = @()

foreach ($name in $GroupName) {
    $safe   = ConvertTo-ODataString $name
    $groups = @(Get-MgGroup -Filter "displayName eq '$safe'")
    if ($groups.Count -eq 0) { throw "Group '$name' was not found." }
    if ($groups.Count -gt 1) { throw "Group name '$name' matches $($groups.Count) groups. Use a unique name." }

    $targets += [pscustomobject]@{
        Kind         = 'Group'
        Name         = $name
        OriginId     = $groups[0].Id
        OriginSystem = 'AadGroup'
    }
}

foreach ($name in $ApplicationName) {
    $safe = ConvertTo-ODataString $name
    $sps  = @(Get-MgServicePrincipal -Filter "displayName eq '$safe'")
    if ($sps.Count -eq 0) { throw "Enterprise application '$name' was not found." }
    if ($sps.Count -gt 1) { throw "Application name '$name' matches $($sps.Count) service principals. Use a unique name." }

    $targets += [pscustomobject]@{
        Kind         = 'Application'
        Name         = $name
        OriginId     = $sps[0].Id
        OriginSystem = 'AadApplication'
    }
}

foreach ($target in $targets) {
    if ($existingOrigins -contains $target.OriginId) {
        Write-Host "[skip] $($target.Kind) '$($target.Name)' is already in catalog '$($catalog.DisplayName)'."
        continue
    }

    $request = @{
        requestType = 'adminAdd'
        resource    = @{
            originId     = $target.OriginId
            originSystem = $target.OriginSystem
        }
        catalog     = @{ id = $catalog.Id }
    }

    $action = "Add $($target.Kind) '$($target.Name)' to catalog '$($catalog.DisplayName)'"
    if ($PSCmdlet.ShouldProcess($catalog.DisplayName, $action)) {
        $null = New-MgEntitlementManagementResourceRequest -BodyParameter $request
        Write-Host "[ok]   $action" -ForegroundColor Green
    }
}

# Resource requests are processed asynchronously; give the service a moment before listing.
if (-not $WhatIfPreference) {
    Start-Sleep -Seconds 5
    Get-CatalogResources -CatalogId $catalog.Id |
        Select-Object DisplayName, ResourceType, OriginSystem, OriginId |
        Format-Table -AutoSize
}
