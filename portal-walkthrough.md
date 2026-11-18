# Portal walkthrough

Performed in the Microsoft Entra admin center (`https://entra.microsoft.com`) on 2026-11-17. Account details are blacked out in the screenshots. Labels below match what the portal showed.

Navigation path used throughout: **ID Governance > Catalogs**.

## 1. Open Catalogs

Before starting, the only catalog in the tenant was the built-in **General** catalog.

![Catalogs list before the lab](screenshots/01-catalogs-list-before.png)

## 2. Create the catalog

Select **New catalog** and fill in the pane:

| Field | Value used |
|---|---|
| Name | `IAM-Lab-Catalog` |
| Description | Lab catalog for IAM automation portfolio: groups, apps, and SharePoint sites used to build access packages. Safe to delete. |
| Enabled for users to request | Yes (default) |
| Enabled for external users to request | No (default) |

![New catalog pane](screenshots/02-new-catalog-form.png)

Select **Create**. The portal confirms with a "Catalog created successfully" toast and the catalog appears in the list.

![Catalog created](screenshots/03-catalog-created.png)

Opening the catalog shows the Overview with zero resources, access packages, and owners.

![Empty catalog overview](screenshots/04-catalog-overview-empty.png)

## 3. Add resources

Catalog > **Resources** > **Add resources**. The pane offers these resource types: Groups and Teams, Applications, SharePoint sites, Azure Resources, Microsoft Entra role (Preview), and Custom Data Provided Resource.

![Add resources pane](screenshots/05-add-resources-pane.png)

Select **Groups and Teams**, tick **Application Team** and **Developers**, then **Select**.

![Select groups](screenshots/06-select-groups.png)

Back on the Add resources pane the two groups are listed under *Selected resources*. Select **Add**. The portal reports "Added 2 of 2 new resources" and both rows show as *Group and Team*, subtype *Security*, onboarded *Yes*.

![Resources added](screenshots/07-resources-added.png)

Groups must be cloud-created. Groups synced from on-premises Active Directory cannot be added.

## 4. Add a catalog owner

Catalog > **Roles and administrators**. Right after creation the list was empty ("No results"). The toolbar offers **Add catalog owner**, **Add catalog reader**, and **Add access package manager**.

Select **Add catalog owner**, pick the member (users, groups, and enterprise applications can be picked), then **Select**. The portal confirms "Added member to catalog as Catalog owner" and the table shows the user with the role *Catalog owner*.

![Catalog owner added](screenshots/08-catalog-owner-added.png)

## 5. Edit the catalog

Catalog > **Overview** > **Edit**. Name, description, and both *Enabled* toggles are editable. The description was changed, then **Save**. The portal shows "Catalog updated successfully", and the Contents section now reads 2 Groups and Teams, 0 Apps, 1 Owner.

![Catalog edited](screenshots/09-catalog-edited.png)

## 6. Delete the catalog (not performed)

Catalog > **Overview** > **Delete**, then **Yes** in the confirmation box. A catalog can only be deleted when it has no access packages. This step was left out so the lab catalog remains for inspection. The scripted version is `scripts/Remove-LabCatalog.ps1`.

## Scripted equivalent

| Portal step | Script |
|---|---|
| 2. Create | `scripts/New-LabCatalog.ps1` |
| 3. Add resources | `scripts/Add-CatalogResource.ps1` |
| 4. Add owner | `scripts/Add-CatalogOwner.ps1` |
| 5. Edit | `scripts/Update-LabCatalog.ps1` |
| 6. Delete | `scripts/Remove-LabCatalog.ps1` |
