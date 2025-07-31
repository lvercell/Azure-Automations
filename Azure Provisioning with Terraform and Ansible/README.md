# 🛠️ Azure Provisioning with Terraform and Ansible

This is a step-by-step hybrid automation lab using **Terraform** for Azure infrastructure provisioning and **Ansible** for VM configuration.  
It's part of the [Azure Automations](../) collection by Lucas Vercellini.

---

## 🎯 Goal

Provision a secure virtual environment in Azure, including:

- Virtual Network, Subnets, NSG
- Public IP and NIC
- Windows VM with hardening
- Domain join + Entra ID Sync
- Optional: Access via Azure Bastion (secure RDP)

---

## 🧱 Tech Stack

| Tool        | Purpose                          |
|-------------|----------------------------------|
| Terraform   | Provision Azure infrastructure   |
| Ansible     | Configure and secure the VM      |
| Azure CLI   | Authentication and local tests   |
| PowerShell  | AD DS setup and Entra Connect    |
| Microsoft Azure | Cloud platform used          |

```plaintext

## 📁 Folder Structure

Azure Provisioning with Terraform and Ansible/
├── ansible/ # Ansible playbooks
│ └── main.yml
├── terraform/ # Terraform IaC definitions
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── lab.tfvars
├── docs/ # Lab documentation (PDFs, images)
│ └── Phase_1_Readme.pdf
└── README.md # This file

```
---

## 🚀 Lab Phases

Each phase is documented with images and clear steps:

| Phase | Description                                      | Link to PDF        |
|-------|--------------------------------------------------|--------------------|
| 1     | Terraform – Deploy core infrastructure           | [Phase 1 PDF](./docs/Phase_1_Readme.pdf) |
| 2     | Configure Domain Controller & promote to DC      | *Coming soon*      |
| 3     | Install and configure Microsoft Entra Connect    | *Coming soon*      |
| 4     | Ansible – Join VM to domain, hardening & tools   | *Coming soon*      |
| 5     | Azure Bastion setup for secure remote access     | *Coming soon*      |

---

## 🧠 Prerequisites

- Azure Subscription (free tier is enough for testing)
- Basic Terraform knowledge
- WSL2 or Linux subsystem (optional, for Ansible)
- VM SKU availability in your selected Azure region

---

## ✅ Status

- ✅ Phase 1: Terraform infrastructure deployed
- 🔄 Phase 2–5: In development
- 📌 Manual and screenshots available under `docs/`

---

## 📌 Notes

- All names and configurations are for **lab purposes only**.
- No sensitive data is included.
- Please review quotas and regional limitations if using free accounts.

---

## 👨‍💻 Author

**Lucas Román Vercellini**  
💡 IT Infrastructure & Automation | DevOps Learner | Hybrid Environments  
🔗 [GitHub](https://github.com/lvercell)  
🔗 [LinkedIn](https://www.linkedin.com/in/lucas-vercellini)

---

## 📖 License

This project is shared for educational and professional purposes.  
Feel free to fork, use and adapt.  
License: MIT / unrestricted.
