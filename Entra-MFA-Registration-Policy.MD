
# Configure the Microsoft Entra ID MFA Registration Policy (Step-by-Step)

A walkthrough of the **Multifactor authentication registration policy** in Microsoft Entra ID Protection (formerly Azure AD Identity Protection). The policy makes users register for Microsoft Entra multifactor authentication (MFA) so they can answer MFA prompts later.

Every screenshot has **red numbered badges**. The number in the step text matches the badge in the image, so you can follow along click by click.

> Screenshots were taken in the Microsoft Entra admin center in a lab tenant. Account emails, tenant IDs and object IDs are blurred.

---

<img width="1352" height="693" alt="05-assignments-include" src="https://github.com/user-attachments/assets/18f86d81-010f-43d6-9dd2-23afaa54df63" />

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

<img width="1352" height="693" alt="01-entra-admin-center-home" src="https://github.com/user-attachments/assets/45b67279-80cf-49ea-872c-92eb6547bb58" />


---

## Step 2 – Locate the policy

Microsoft's documentation describes the path as **Protection > Identity Protection > Multifactor authentication registration policy**. In the current portal the left menu looks different. Under **ID Protection (1)** you only see *Dashboard, Risk-based Conditional Access, Risky users, Risky workload identities* and *Risky agents*, so the policy is not listed there.

![Step 2a – ID Protection menu]<img width="1352" height="693" alt="02-id-protection-menu" src="https://github.com/user-attachments/assets/0535fe22-e969-4880-a43e-8e7c786b5802" />


Use the search box instead:

1. Click the search box **(1)** at the top of the portal and type `multifactor authentication registration policy`.
2. Under **Services**, select **Multifactor Authentication Registration Policies (2)**.

![Step 2b – Search for the policy](<img width="1427" height="540" alt="Role-page" src="https://github.com/user-attachments/assets/c82c3512-2d4e-443b-93b5-ae93bd74244a" />
<img width="1352" height="693" alt="04-policy-overview" src="https://github.com/user-attachments/assets/59e1c745-41dc-495d-935c-7b2f56b2d59c" />


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

![Step 3 – Policy overview]<img width="1352" height="693" alt="04-policy-overview" src="https://github.com/user-attachments/assets/5964e1d1-53e2-4cd1-97a7-b03be78dd2f4" />


---

## Step 4 – Choose who the policy applies to (Include)

1. Click **All users (1)** under *Assignments > Users*. This opens the **Include** tab.
2. Choose one of the two options:
   - **All users (2)**: the recommended default, which applies the policy tenant-wide.
   - **Select individuals and groups (3)**: use this to pilot the rollout with a limited group first.

![Step 4 – Include tab]<img width="1352" height="693" alt="05-assignments-include" src="https://github.com/user-attachments/assets/ac0b782e-ad3b-4a2a-8ec3-75fa8454e0a8" />


---

## Step 5 – Exclude accounts (optional)

1. Select the **Exclude** tab **(1)**.
2. Click the **users and groups selected (2)** link to open the picker. In this lab it shows **0 users and groups selected**.

![Step 5a – Exclude tab]<img width="1352" height="693" alt="06-assignments-exclude" src="https://github.com/user-attachments/assets/18fc4ef7-fb05-4159-adf8-8639dd08986a" />

In the **Select users** pane:

1. Use the search box **(1)** or the *All / Users / Groups* tabs to find the account or group.
2. Tick the checkbox **(2)** next to each user or group you want to exclude.
3. Click **Select (3)**.

![Step 5b – Select users and groups]<img width="1352" height="693" alt="07-select-users-and-groups-picker" src="https://github.com/user-attachments/assets/cb2eb7d6-2d09-4c32-b73c-3390ff63ccd0" />


> **Production tip:** As with Conditional Access policies, keep your emergency-access (break-glass) accounts out of scope so a policy mistake can never lock every administrator out. The lab tenant has no dedicated emergency-access account, so nothing was excluded here.

---

## Step 6 – Enable enforcement and save

1. Set **Policy enforcement** to **Enabled (3)**.
2. Click **Save (4)**.

The **Save** button is only active after you change a setting. In this lab tenant the policy was already **Enabled** for **All users**, so **Save** is greyed out. That is the desired end state, and no further change was needed.

![Step 6 – Final state]<img width="1352" height="693" alt="08-policy-final-state" src="https://github.com/user-attachments/assets/1a9c891b-655b-48b1-8eb9-c1d4f3cf2b28" />


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
