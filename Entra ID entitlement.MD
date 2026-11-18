# Configure the Microsoft Entra ID MFA Registration Policy (Step-by-Step)

A walkthrough of the **Multifactor authentication registration policy** in Microsoft Entra ID Protection (formerly Azure AD Identity Protection). The policy makes users register for Microsoft Entra multifactor authentication (MFA) so they can answer MFA prompts later.

Every screenshot has **red numbered badges**. The number in the step text matches the badge in the image, so you can follow along click by click.

> Screenshots were taken in the Microsoft Entra admin center in a lab tenant. Account emails, tenant IDs and object IDs are blurred.

---

## Contents

1. [Prerequisites](#prerequisites)
2. [Step 1 – Sign in to the Entra admin center](#step-1--sign-in-to-the-entra-admin-center)
3. [Step 2 – Locate the policy](#step-2--locate-the-policy)
4. [Step 3 – Review the policy page](#step-3--review-the-policy-page)
5. [Step 4 – Choose who the policy applies to (Include)](#step-4--choose-who-the-policy-applies-to-include)
6. [Step 5 – Exclude accounts (optional)](#step-5--exclude-accounts-optional)
7. [Step 6 – Enable enforcement and save](#step-6--enable-enforcement-and-save)
8. [Final configuration](#final-configuration)
9. [What users will experience](#what-users-will-experience)
10. [Related and references](#related-and-references)

---

## Prerequisites

| Requirement | Detail |
|---|---|
| Role | At least **Security Administrator** (a Global Administrator also works) |
| Feature | Microsoft Entra ID Protection (part of Microsoft Entra ID P2 licensing) |
| Portal | <https://entra.microsoft.com> |

---

## Step 1 – Sign in to the Entra admin center

1. Browse to <https://entra.microsoft.com>.
2. Sign in with an account that holds the Security Administrator or Global Administrator role.
3. On the **Home** page, confirm **(1)** the role shown under your name, here **Global Administrator**. The search box **(2)** is what you will use in the next step.

![Step 1 – Entra admin center home](01-entra-admin-center-home.png)

---

## Step 2 – Locate the policy

Microsoft's documentation describes the path as **Protection > Identity Protection > Multifactor authentication registration policy**. In the current portal the left menu looks different. Under **ID Protection (1)** you only see *Dashboard, Risk-based Conditional Access, Risky users, Risky workload identities* and *Risky agents*, so the policy is not listed there.

![Step 2a – ID Protection menu](02-id-protection-menu.png)

Use the search box instead:

1. Click the search box **(1)** at the top of the portal and type `multifactor authentication registration policy`.
2. Under **Services**, select **Multifactor Authentication Registration Policies (2)**.

![Step 2b – Search for the policy](03-search-mfa-registration-policy.png)

---

## Step 3 – Review the policy page

The policy page has four areas, numbered in the screenshot:

| Badge | Area | What it does |
|---|---|---|
| **1** | **Assignments > Users** | Sets which users and groups the policy applies to (opens the Include and Exclude tabs). |
| **2** | **Controls** | *Require Microsoft Entra ID multifactor authentication registration*. This box is checked and cannot be changed. |
| **3** | **Policy enforcement** | **Enabled** or **Disabled** toggle. |
| **4** | **Save** | Stays greyed out until you change something. |

The blue banner explains that this policy only affects **cloud-based** Microsoft Entra MFA. It does not affect an on-premises MFA Server.

![Step 3 – Policy overview](04-policy-overview.png)

---

## Step 4 – Choose who the policy applies to (Include)

1. Click **All users (1)** under *Assignments > Users*. This opens the **Include** tab.
2. Choose one of the two options:
   - **All users (2)**: the recommended default, which applies the policy tenant-wide.
   - **Select individuals and groups (3)**: use this to pilot the rollout with a limited group first.

![Step 4 – Include tab](05-assignments-include.png)

---

## Step 5 – Exclude accounts (optional)

1. Select the **Exclude** tab **(1)**.
2. Click the **users and groups selected (2)** link to open the picker. In this lab it shows **0 users and groups selected**.

![Step 5a – Exclude tab](06-assignments-exclude.png)

In the **Select users** pane:

1. Use the search box **(1)** or the *All / Users / Groups* tabs to find the account or group.
2. Tick the checkbox **(2)** next to each user or group you want to exclude.
3. Click **Select (3)**.

![Step 5b – Select users and groups](07-select-users-and-groups-picker.png)

> **Production tip:** As with Conditional Access policies, keep your emergency-access (break-glass) accounts out of scope so a policy mistake can never lock every administrator out. The lab tenant has no dedicated emergency-access account, so nothing was excluded here.

---

## Step 6 – Enable enforcement and save

1. Set **Policy enforcement** to **Enabled (3)**.
2. Click **Save (4)**.

The **Save** button is only active after you change a setting. In this lab tenant the policy was already **Enabled** for **All users**, so **Save** is greyed out. That is the desired end state, and no further change was needed.

![Step 6 – Final state](08-policy-final-state.png)

---

## Final configuration

| Setting | Value |
|---|---|
| Users – Include | All users |
| Users – Exclude | None in the lab. Emergency-access accounts in production. |
| Require Microsoft Entra ID multifactor authentication registration | Checked (fixed, cannot be changed) |
| Policy enforcement | **Enabled** |

---

## What users will experience

Once the policy is enabled, Microsoft Entra ID Protection prompts users to register the next time they sign in interactively. They have **14 days** to complete registration. During that window they can skip registration when MFA isn't otherwise required, but when the 14 days end they must register before the sign-in can complete.

Registration only gives users something to use for MFA. To actually **require** MFA at sign-in, pair this policy with a Conditional Access policy.

---

## Related and references

- [How to configure the multifactor authentication registration policy (Microsoft Learn)](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-configure-mfa-policy)
- [Protect security info registration with Conditional Access (Microsoft Learn)](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration), a Conditional Access alternative using the *Register security information* user action
- [Plan a Microsoft Entra multifactor authentication deployment (Microsoft Learn)](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted)
