# User Provisioning via Microsoft Graph

This folder contains a ready-to-use PowerShell script that automates the creation of users and groups in Microsoft Entra ID (Azure AD) using Microsoft Graph API.

The script:

- Reads user information from a CSV file
- Creates missing groups
- Creates users with assigned passwords
- Adds each user to the appropriate group
- Generates a `log.txt` and a `created_users.csv` with results

---

## 📦 Files

| File                   | Description                              |
|------------------------|------------------------------------------|
| `CreateUsersAndGroups.ps1` | Main automation script (English version) |
| `users.csv`            | Example input file for bulk provisioning |
| `log.txt`              | Execution log (auto-generated)           |
| `created_users.csv`    | Output: successfully created users       |

---

## ✅ Requirements

- PowerShell 7 (recommended)
- Microsoft Graph PowerShell SDK (`Install-Module Microsoft.Graph`)
- A valid Azure AD tenant with permissions to create users and groups
- A registered app or delegated access with:
  - `User.ReadWrite.All`
  - `Group.ReadWrite.All`
  - `Directory.Read.All`

---

## 🚀 How to use

1. Clone or download this repository
2. Update the `users.csv` file with your user data
3. Run PowerShell as administrator
4. Execute the script:

```powershell
.\CreateUsersAndGroups.ps1
