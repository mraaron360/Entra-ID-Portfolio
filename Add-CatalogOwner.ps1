<#
.SYNOPSIS
    Assigns a catalog role (Owner by default) to users, groups, or service principals.

.DESCRIPTION
    Portal equivalent: Catalog > Roles and administrators > Add catalog owner / reader / access package manager.
    Graph API:         POST /roleManagement/entitlementManagement/roleAssignments
                       (appScopeId = /AccessPackageCatalog/{catalogId})

    A catalog owner can add other users, groups of users, or application service principals as owners.
    Existing identical assignments are skipped, so the script is safe to re-run.

.PARAMETER CatalogName
    Display name of the catalog.

.PARAMETER CatalogId
    Object ID of the catalog (use instead of -CatalogName).

.PARAMETER UserPrincipalName
    One or more user principal names to assign.

.PARAMETER PrincipalId
    One or more object IDs (user, group, or service principal) to assign.

.PARAMETER Role
    Owner (default), Reader, or AccessPackageManager.

.EXAMPLE
    ./scripts/Add-CatalogOwner.ps1 -CatalogName 'IAM-Lab-Catalog' -UserPrincipalName 'user@contoso.com' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory, ParameterSetName = 'ByName')][string]$CatalogName,
    [Parameter(Mandatory, ParameterSetName = 'ById')][string]$CatalogId,
    [string[]]$UserPrincipalName = @(),
    [string[]]$PrincipalId = @(),
    [ValidateSet('Owner', 'Reader', 'AccessPackageManager')][string]$Role = 'Owner'
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Common.ps1"

Assert-GraphContext -RequiredScopes 'EntitlementManagement.ReadWrite.All'

if ($UserPrincipalName.Count -eq 0 -and $PrincipalId.Count -eq 0) {
    throw 'Specify at least one -UserPrincipalName or -PrincipalId.'
}

$catalog = Resolve-Catalog -CatalogName $CatalogName -CatalogId $CatalogId
$scope   = "/AccessPackageCatalog/$($catalog.Id)"
$roleId  = $CatalogRoleIds[$Role]

# Resolve everything up front so a typo fails before anything is changed.
$principals = @()

foreach ($upn in $UserPrincipalName) {
    $user = Get-MgUser -UserId $upn
    $principals += [pscustomobject]@{ Label = $upn; Id = $user.Id }
}
foreach ($id in $PrincipalId) {
    $principals += [pscustomobject]@{ Label = $id; Id = $id }
}

$current = @(Get-CatalogRoleAssignments -CatalogId $catalog.Id)

foreach ($principal in $principals) {
    $already = $current | Where-Object { $_.PrincipalId -eq $principal.Id -and $_.RoleDefinitionId -eq $roleId }
    if ($already) {
        Write-Host "[skip] $($principal.Label) already has the $Role role on '$($catalog.DisplayName)'."
        continue
    }

    $assignment = @{
        principalId      = $principal.Id
        roleDefinitionId = $roleId
        appScopeId       = $scope
    }

    $action = "Assign $Role on catalog '$($catalog.DisplayName)' to $($principal.Label)"
    if ($PSCmdlet.ShouldProcess($catalog.DisplayName, $action)) {
        $null = New-MgRoleManagementEntitlementManagementRoleAssignment -BodyParameter $assignment
        Write-Host "[ok]   $action" -ForegroundColor Green
    }
}
