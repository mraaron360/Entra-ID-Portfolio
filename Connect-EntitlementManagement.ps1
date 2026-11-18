<#
.SYNOPSIS
    Signs in to Microsoft Graph with the delegated scopes used by the catalog scripts.

.DESCRIPTION
    Interactive sign-in only. No secrets, tokens, or tenant details are stored in this repository.
    The signed-in account still needs an Entra role that can manage entitlement management,
    such as Identity Governance Administrator.

.PARAMETER TenantId
    Optional tenant ID or domain to sign in to.

.PARAMETER Scopes
    Delegated Graph scopes to request. The default covers every script in this repo for
    groups. Add Application.ReadWrite.All if you also add applications as catalog resources.

.EXAMPLE
    ./scripts/Connect-EntitlementManagement.ps1

.EXAMPLE
    ./scripts/Connect-EntitlementManagement.ps1 -Scopes 'EntitlementManagement.ReadWrite.All','Group.ReadWrite.All','User.Read.All','Application.ReadWrite.All'
#>
[CmdletBinding()]
param(
    [string]$TenantId,

    [string[]]$Scopes = @(
        'EntitlementManagement.ReadWrite.All',
        'Group.ReadWrite.All',
        'User.Read.All'
    )
)

$ErrorActionPreference = 'Stop'

$minimumVersion = [version]'2.4.0'
$requiredModules = @(
    'Microsoft.Graph.Authentication',
    'Microsoft.Graph.Identity.Governance',
    'Microsoft.Graph.Groups',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Applications'
)

foreach ($name in $requiredModules) {
    $module = Get-Module -ListAvailable -Name $name | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $module -or $module.Version -lt $minimumVersion) {
        throw "Module '$name' $minimumVersion or later is required. Run: Install-Module Microsoft.Graph -Scope CurrentUser"
    }
}

$connectParams = @{
    Scopes    = $Scopes
    NoWelcome = $true
}
if ($TenantId) { $connectParams['TenantId'] = $TenantId }

Connect-MgGraph @connectParams

$context = Get-MgContext
Write-Host "Connected as $($context.Account) (tenant $($context.TenantId))" -ForegroundColor Green
Write-Host "Scopes: $($context.Scopes -join ', ')"
