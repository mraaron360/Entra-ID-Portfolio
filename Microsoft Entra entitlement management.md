

# Microsoft Entra Entitlement Management: Catalog Lab

Create and manage a **catalog of resources** in Microsoft Entra entitlement management



| Step | Result |
|---|---|
| Create catalog | `IAM-Lab-Catalog`, enabled for users to request, not enabled for external users |
| Add resources | 2 groups (`Application Team`, `Developers`), type *Group and Team*, subtype *Security*, onboarded |
| Add catalog owner | 1 owner added through *Roles and administrators* |
| Edit catalog | Description updated from the Overview page |
| Delete catalog | Documented and scripted, intentionally **not** run so the lab stays inspectable |

## Repository layout

```
.
├── README.md
├── LICENSE
├── .gitignore
├── config/
│   └── catalog.sample.json        # input for Invoke-LabWorkflow.ps1
├── docs/
│   ├── portal-walkthrough.md      # click-by-click with screenshots
│   └── screenshots/               # account details redacted
└── scripts/
    ├── Common.ps1                 # shared helpers (dot-sourced)
    ├── Connect-EntitlementManagement.ps1
    ├── New-LabCatalog.ps1
    ├── Add-CatalogResource.ps1
    ├── Add-CatalogOwner.ps1
    ├── Update-LabCatalog.ps1
    ├── Remove-CatalogResource.ps1
    ├── Remove-LabCatalog.ps1
    ├── Get-LabCatalog.ps1         # read-only verification
    └── Invoke-LabWorkflow.ps1     # runs the whole lab from a JSON config
```

## Prerequisites

- A tenant with Microsoft Entra ID Governance licensing for entitlement management. The portal shows a banner that a linked Azure subscription is required to use ID Governance features for **guest** users; this lab only uses members and groups.
- An Entra role that can manage entitlement management. **Identity Governance Administrator** is the minimum for the whole lab. *Catalog creator* can create catalogs, and *Catalog owner* can manage resources and owners in a catalog they own.
- PowerShell 7+ and the Microsoft Graph PowerShell SDK **2.4.0 or later**:
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  ```
- Groups added as resources must be **cloud-created** security or Microsoft 365 groups. Groups synced from on-premises Active Directory cannot be added.

## Quick start

```powershell
git clone https://github.com/mraaron360/entra-entitlement-catalog.git
cd entra-entitlement-catalog

./scripts/Connect-EntitlementManagement.ps1          # interactive sign-in, no secrets stored

# Preview, then run
./scripts/New-LabCatalog.ps1 -DisplayName 'IAM-Lab-Catalog' -Description 'Lab catalog' -WhatIf
./scripts/New-LabCatalog.ps1 -DisplayName 'IAM-Lab-Catalog' -Description 'Lab catalog'

./scripts/Add-CatalogResource.ps1 -CatalogName 'IAM-Lab-Catalog' -GroupName 'Application Team','Developers'
./scripts/Add-CatalogOwner.ps1    -CatalogName 'IAM-Lab-Catalog' -UserPrincipalName 'user@your-tenant.onmicrosoft.com'
./scripts/Update-LabCatalog.ps1   -CatalogName 'IAM-Lab-Catalog' -Description 'Updated description'
./scripts/Get-LabCatalog.ps1      -CatalogName 'IAM-Lab-Catalog'
```

Or drive everything from a config file:

```powershell
Copy-Item config/catalog.sample.json config/catalog.local.json   # *.local.json is git-ignored
# edit the owner UPN and group names, then:
./scripts/Invoke-LabWorkflow.ps1 -ConfigPath ./config/catalog.local.json -WhatIf
./scripts/Invoke-LabWorkflow.ps1 -ConfigPath ./config/catalog.local.json
```

Every script that changes the tenant supports `-WhatIf` and `-Confirm`. Re-running is safe: existing catalogs, resources, and role assignments are detected and skipped.

## Portal task to script to Graph API

| Task | Portal path | Script | Cmdlet | Graph API |
|---|---|---|---|---|
| Create | ID Governance > Catalogs > New catalog | `New-LabCatalog.ps1` | `New-MgEntitlementManagementCatalog` | `POST /identityGovernance/entitlementManagement/catalogs` |
| Add resources | Catalog > Resources > Add resources | `Add-CatalogResource.ps1` | `New-MgEntitlementManagementResourceRequest` (`adminAdd`) | `POST /identityGovernance/entitlementManagement/resourceRequests` |
| Add owner | Catalog > Roles and administrators > Add catalog owner | `Add-CatalogOwner.ps1` | `New-MgRoleManagementEntitlementManagementRoleAssignment` | `POST /roleManagement/entitlementManagement/roleAssignments` |
| Edit | Catalog > Overview > Edit | `Update-LabCatalog.ps1` | `Update-MgEntitlementManagementCatalog` | `PATCH /identityGovernance/entitlementManagement/catalogs/{id}` |
| Remove resource | Catalog > Resources > Remove | `Remove-CatalogResource.ps1` | `New-MgEntitlementManagementResourceRequest` (`adminRemove`) | `POST /identityGovernance/entitlementManagement/resourceRequests` |
| Delete | Catalog > Overview > Delete | `Remove-LabCatalog.ps1` | `Remove-MgEntitlementManagementCatalog` | `DELETE /identityGovernance/entitlementManagement/catalogs/{id}` |

Portal toggle mapping when creating or editing a catalog: *Enabled for users to request* is `state` (`published` or `unpublished`), and *Enabled for external users to request* is `isExternallyVisible`.

### Delegated permissions

| Scope | Used for |
|---|---|
| `EntitlementManagement.ReadWrite.All` | Every script |
| `Group.ReadWrite.All` | Adding groups as resources |
| `User.Read.All` | Resolving a UPN when assigning an owner |
| `Application.ReadWrite.All` | Only if you add enterprise applications (request it with `-Scopes`) |

Scopes are what the *app* may do. The signed-in account still needs the Entra roles listed under prerequisites, and, for resources, must own the resource or hold a role that can modify it.

### Catalog role definition IDs

| Role | Role definition ID |
|---|---|
| Catalog owner | `ae79f266-94d4-4dab-b730-feca7e132178` |
| Catalog reader | `44272f93-9762-48e8-af59-1b5351b1d6b3` |
| Access package manager | `7f480852-ebdc-47d4-87de-0d8498384a83` |
| Catalog creator (tenant-wide role) | `ba92d953-d8e0-4e39-a797-0cbedb0a89e8` |

Catalog-scoped assignments use `appScopeId = /AccessPackageCatalog/{catalogId}`.

## Notes and gotchas

- **The creator is not always listed as an owner.** In this tenant the *Roles and administrators* page was empty right after the catalog was created (0 owners on the Overview), so the owner was added explicitly.
- **Resources before access packages.** A resource must be in a catalog before one of its roles can go into an access package.
- **Removal rules.** A resource can only be removed from a catalog if no access package in the catalog uses it, and a catalog can only be deleted when it contains no access packages.
- **Resource requests are asynchronous.** `Add-CatalogResource.ps1` waits a few seconds and then lists the catalog's resources; if a resource is missing, run `Get-LabCatalog.ps1` again.
- **User Administrator is no longer enough.** Assign Identity Governance Administrator (or Catalog creator) instead.
- **Duplicate names.** The portal requires a unique catalog name; the scripts resolve catalogs by name and stop if a name is ambiguous (use `-CatalogId`).

## Status and testing

The portal workflow was executed live. The scripts follow the documented v1.0 Graph PowerShell cmdlets and request shapes, but they have **not** been run against a tenant yet. Run each one with `-WhatIf` first. A quick parser check without touching Graph:

```powershell
Get-ChildItem ./scripts -Filter *.ps1 | ForEach-Object {
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errors)
    if ($errors) { $errors | ForEach-Object { "$($_.Extent.File):$($_.Extent.StartLineNumber) $($_.Message)" } }
    else { "OK  $($_.Name)" }
}
```

## Cleanup

```powershell
./scripts/Remove-LabCatalog.ps1 -CatalogName 'IAM-Lab-Catalog' -WhatIf
./scripts/Remove-LabCatalog.ps1 -CatalogName 'IAM-Lab-Catalog'
```

## Screenshots

<img width="1352" height="693" alt="09-catalog-edited" src="https://github.com/user-attachments/assets/fd1cc95d-3890-4d43-82e5-c392bcd94826" />
<img width="1352" height="693" alt="08-catalog-owner-added" src="https://github.com/user-attachments/assets/1a18d648-75fe-4875-bb9d-789c4d7045d6" />
<img width="1352" height="693" alt="07-resources-added" src="https://github.com/user-attachments/assets/624f04de-b4e1-4136-8ead-71ce7b666fae" />
<img width="1352" height="693" alt="06-select-groups" src="https://github.com/user-attachments/assets/1feb2fda-32f9-4967-9050-acbdeeafa227" />
<img width="1352" height="693" alt="05-add-resources-pane" src="https://github.com/user-attachments/assets/20450e18-b590-4b32-980e-acb07b58ecb7" />
<img width="1352" height="693" alt="04-catalog-overview-empty" src="https://github.com/user-attachments/assets/c4892ded-d626-4dac-b3ef-b211d8a6c602" />
<img width="1352" height="693" alt="03-catalog-created" src="https://github.com/user-attachments/assets/1aea57ab-e97a-45ab-a789-a03973b31cbb" />
<img width="1352" height="693" alt="02-new-catalog-form" src="https://github.com/user-attachments/assets/cde32599-c1b1-46bd-a730-6a7979fe9f10" />
<img width="1352" height="693" alt="01-catalogs-list-before" src="https://github.com/user-attachments/assets/6af70f1d-8ee6-4f53-b663-e8bc0c4b3f7b" />

