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

---

### 🧩 How to assign users to multiple groups (optional enhancement)

By default, the script reads one group per user from the `Group` column in the CSV file.  
If you want to assign users to **multiple groups**, here are two common approaches:

#### Option 1: Use a comma-separated list in the CSV

```csv
DisplayName,UserPrincipalName,MailNickname,Password,Group
Jane Doe,jane@domain.com,jane,password123,"HR,Finance,RemoteAccess"

You would then need to modify the script so it:
    Splits the Group string by comma
    Iterates over each group name
    Ensures each group exists and adds the user to all of them

    🛠 This logic is not included in the current version of the script, but can be easily added with a foreach loop over the groups.

Option 2: Use an additional column per group (not recommended for scale)
This approach requires adding Group1, Group2, etc., as separate columns in the CSV. It's less flexible and harder to maintain.
Let me know if you’d like a future version of the script with multi-group support built-in.
