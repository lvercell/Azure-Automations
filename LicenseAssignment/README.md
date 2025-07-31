# 📦 Bulk License Assignment with Azure Automation

This folder contains a **step-by-step automation lab** to simulate **massive license assignment** in **Azure Active Directory**, using **Azure Automation**, **Managed Identity**, and **PowerShell Runbooks** based on CSV files.

🧾 **Documentation**: [`2 - Massive licences assignment with Azure Automation.pdf`](./docs/2%20-%20Massive%20licences%20assignment%20with%20Azure%20Automation.pdf)  
🧪 **Status**: ✅ Completed and tested in lab environment  
🔧 **Next step**: Role Assignment automation (coming soon)

---

## 🔍 What you'll learn

- ✅ Uploading CSVs to Azure Storage securely
- ✅ Using Managed Identity to authenticate from Runbooks
- ✅ Processing user data and simulating license assignment
- ✅ (Optional) Creating users and assigning to groups
- ✅ Best practices and real-world considerations

---

## 📘 Manual Contents

The included PDF explains:

- Required roles and permissions
- Azure Automation Account & Storage setup
- Variable creation and CSV preparation
- Sample Runbook code with validation logic
- Common issues and troubleshooting

---

## 📁 Folder Structure

```plaintext
LicenseAssignment/
├── scripts/
│   └── CrearUsuariosConGrupos.ps1       # Creates users and assigns to groups
├── csv/
│   ├── users.csv                        # Input file (main)
│   └── created_users.csv                # Generated result (optional)
├── docs/
│   └── 2 - Massive licences assignment with Azure Automation.pdf
├── logs/
│   └── log.txt                          # Execution output (optional)
└── README.md                            # This file
```
## 🚀 Getting Started

1. **Read the lab manual**  
   → [PDF available here](./docs/2%20-%20Massive%20licences%20assignment%20with%20Azure%20Automation.pdf)

2. **Prepare the Azure environment**
   - Create an Automation Account
   - Create a Storage Account
   - Enable Managed Identity

3. **Upload the CSV file** (`usuarios.csv`) to Blob Storage  
   Create a container named `csv`, then upload the file using PowerShell or Azure Portal.

4. **Create the Automation Variable**
   - Name: `CsvStorageConnection`
   - Type: String
   - Value: (your Azure Storage connection string)

5. **Run the simulation**
   - Use the PowerShell Runbook to simulate license assignment
   - Check logs, results and the optional CSV outputs


## 📂 Key Files

| File                          | Description                                     |
|------------------------------|-------------------------------------------------|
| `CrearUsuariosConGrupos.ps1` | PowerShell script to create users from CSV      |
| `usuarios.csv`               | Input with UPNs, groups, and data per user      |
| `created_users.csv`          | Output after simulation or execution            |
| `log.txt`                    | Console output log (optional)                   |
| PDF Manual                   | Full setup instructions and screenshots         |

👨‍💻 Author

Lucas Román Vercellini
🔗 LinkedIn
🔧 IT Infrastructure · Azure Automation · DevOps Learner

    ⚠️ This lab is for testing and education. No real data is included. For production, use secure identities, review license SKUs and permissions thoroughly.
