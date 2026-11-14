# Microsoft Entra ID App Registration and Graph Permissions Lab

## Objective

Register an application in Microsoft Entra ID, configure Microsoft Graph delegated permissions, grant admin consent, and verify the related Enterprise Application service principal.

## Scenario

Application name:

-Developers and Administrators




Access configured:

- Default Microsoft Graph User.Read permission
- Microsoft Graph Group.Read.All delegated permission
- Admin consent granted
- Enterprise Application service principal verified
- User assigned to Enterprise Application

## Evidence

### 1. App Registration Form

<img width="1104" height="706" alt="Screenshot 2026-11-14 at 3 36 31 PM" src="https://github.com/user-attachments/assets/429d8b53-dc7a-465e-88fb-c5622809f82d" />

### 2. App Registration Overview

<img width="1093" height="663" alt="Screenshot 2026-11-14 at 3 37 40 PM" src="https://github.com/user-attachments/assets/2f23ffca-24ac-489c-b1f4-65f55185afab" />



### 3. Default API Permission

<img width="1105" height="698" alt="api" src="https://github.com/user-attachments/assets/7c4682ec-988d-4199-b98a-bd9e089cf411" />


### 4. Graph Permission Selected


<img width="852" height="809" alt="permission" src="https://github.com/user-attachments/assets/d4695792-d066-4aaa-90ae-63c8b037ab82" />


### 5. Permission Added Before Consent

<img width="1097" height="688" alt="Screenshot 2026-11-14 at 3 45 40 PM" src="https://github.com/user-attachments/assets/491a2ccb-7716-45d4-85a4-c486ff084755" />


### 6. Admin Consent Granted


<img width="1120" height="710" alt="Screenshot 2026-11-14 at 3 47 32 PM" src="https://github.com/user-attachments/assets/b59ab0d8-3a06-495b-ab94-dfceadbb29db" />


### 7. Enterprise Application Service Principal


<img width="1440" height="720" alt="doc" src="https://github.com/user-attachments/assets/f468db30-1d26-4d92-b939-59611fd45b8a" />


### 8. Enterprise App User Assignment


<img width="1120" height="710" alt="Screenshot 2026-11-14 at 3 47 32 PM" src="https://github.com/user-attachments/assets/cf482692-1242-4779-b7dd-e079dfcf03b7" />


## What This Proves

- Created a Microsoft Entra ID app registration
- Verified application/client ID, object ID, and tenant ID
- Configured Microsoft Graph delegated API permissions
- Added Group.Read.All permission
- Granted tenant admin consent
- Verified Enterprise Application service principal creation
- Assigned a user to the Enterprise Application

## IAM Skills Demonstrated

- Microsoft Entra ID app registration
- Enterprise Application and service principal validation
- Microsoft Graph API permissions
- Admin consent workflow
- User assignment to enterprise applications
- Application identity lifecycle management
- OAuth permission model understanding

## Security Notes

Group.Read.All allows an application to read group information. In real environments, this permission should be reviewed carefully and granted only when there is a business need.
