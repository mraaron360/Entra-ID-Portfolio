<#
.SYNOPSIS
    Runs the whole catalog lab from a JSON config: create, add resources, assign owners, edit.

.DESCRIPTION
    Reads a config file (see config/catalog.sample.json) and calls the individual scripts in order.
    Every step is idempotent, so re-running after a partial failure is safe.

    With -WhatIf the script only prints the plan from the config. The later steps need the
    catalog to exist, so they cannot be simulated against the tenant.

.PARAMETER ConfigPath
    Path to the JSON config.

.EXAMPLE
    ./scripts/Invoke-LabWorkflow.ps1 -ConfigPath ./config/catalog.sample.json -WhatIf

.EXAMPLE
    ./scripts/Invoke-LabWorkflow.ps1 -ConfigPath ./config/catalog.local.json
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$ConfigPath
)

$ErrorActionPreference = 'Stop'

$config = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json

$name        = $config.catalog.displayName
$description = $config.catalog.description
$enabled     = $true
$external    = $false
if ($null -ne $config.catalog.enabled)           { $enabled  = [bool]$config.catalog.enabled }
if ($null -ne $config.catalog.externallyVisible) { $external = [bool]$config.catalog.externallyVisible }

$groups = @($config.resources.groups       | Where-Object { $_ })
$apps   = @($config.resources.applications | Where-Object { $_ })
$owners = @($config.owners.users           | Where-Object { $_ })

if ($WhatIfPreference) {
    Write-Host "[WhatIf] Plan for catalog '$name':" -ForegroundColor Cyan
    Write-Host "  1. Create catalog (enabled=$enabled, externallyVisible=$external)"
    Write-Host "  2. Add groups:       $(if ($groups) { $groups -join ', ' } else { '(none)' })"
    Write-Host "  3. Add applications: $(if ($apps) { $apps -join ', ' } else { '(none)' })"
    Write-Host "  4. Add owners:       $(if ($owners) { $owners -join ', ' } else { '(none)' })"
    Write-Host "  5. Edit description: $(if ($config.update.description) { 'yes' } else { 'no' })"
    return
}

Write-Host "`n[1/5] Creating catalog '$name'" -ForegroundColor Cyan
$null = & "$PSScriptRoot/New-LabCatalog.ps1" -DisplayName $name -Description $description -Enabled $enabled -ExternallyVisible $external

if ($groups.Count -gt 0 -or $apps.Count -gt 0) {
    Write-Host "`n[2-3/5] Adding resources" -ForegroundColor Cyan
    & "$PSScriptRoot/Add-CatalogResource.ps1" -CatalogName $name -GroupName $groups -ApplicationName $apps
}

if ($owners.Count -gt 0) {
    Write-Host "`n[4/5] Assigning catalog owners" -ForegroundColor Cyan
    & "$PSScriptRoot/Add-CatalogOwner.ps1" -CatalogName $name -UserPrincipalName $owners -Role Owner
}

if ($config.update -and $config.update.description) {
    Write-Host "`n[5/5] Editing catalog description" -ForegroundColor Cyan
    & "$PSScriptRoot/Update-LabCatalog.ps1" -CatalogName $name -Description $config.update.description
}

Write-Host "`nFinal state:" -ForegroundColor Cyan
& "$PSScriptRoot/Get-LabCatalog.ps1" -CatalogName $name
