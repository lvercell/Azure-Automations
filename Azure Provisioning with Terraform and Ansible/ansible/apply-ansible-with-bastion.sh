#!/bin/bash

set -e

# 🌐 Get public IP of the user's machine
USER_IP=$(curl -s ifconfig.me)
echo "🌐 Your public IP is: $USER_IP"

# 📡 Create temporary public IP in Azure
echo "📡 Creating temporary public IP..."
az network public-ip create \
  --resource-group rg-avd-lab \
  --name ip-temp-ansible \
  --sku Standard \
  --allocation-method Static \
  --query publicIp.ipAddress -o tsv

# 🔗 Attach the temp public IP to the NIC
echo "🔗 Associating temp public IP to VM NIC..."
az network nic ip-config update \
  --name ipconfig1 \
  --nic-name nic-avd \
  --resource-group rg-avd-lab \
  --public-ip-address ip-temp-ansible

# 🔐 Open NSG for RDP and WinRM (restricted to your IP)
echo "🔐 Adding temporary NSG rules..."
az network nsg rule create \
  --resource-group rg-avd-lab \
  --nsg-name nsg-avd \
  --name Allow-RDP-Temp \
  --priority 3001 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "$USER_IP" \
  --destination-port-ranges 3389

az network nsg rule create \
  --resource-group rg-avd-lab \
  --nsg-name nsg-avd \
  --name Allow-WinRM-Temp \
  --priority 3002 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "$USER_IP" \
  --destination-port-ranges 5986

# 🔎 Get public IP assigned to the VM
echo "🔎 Detecting actual public IP of the VM..."
VM_PUBLIC_IP=$(az network public-ip show \
  --resource-group rg-avd-lab \
  --name ip-temp-ansible \
  --query ipAddress -o tsv)

if [[ -z "$VM_PUBLIC_IP" ]]; then
  echo "❌ Error: Could not retrieve public IP. Aborting."
  exit 1
fi

echo "✅ Public IP detected: $VM_PUBLIC_IP"

# 📝 Update hosts.ini file with the detected IP
echo "[windows]" > hosts.ini
echo "$VM_PUBLIC_IP" >> hosts.ini
cat <<EOF >> hosts.ini

[windows:vars]
ansible_user=lucas
ANSIBLE_PASSWORD="Admin\$123456.#"
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
EOF

# 🔍 Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible is not installed. Please install it first."
    exit 1
fi

# ⚙️ Run WinRM setup playbook
#echo "⚙️ Running winrm_setup.yml to enable WinRM..."
#ansible-playbook winrm_setup.yml -i hosts.ini

# 🚀 Run main Ansible playbook
echo "🚀 Running main.yml with Ansible..."
ansible-playbook main.yml -i hosts.ini

if [ $? -ne 0 ]; then
  echo "❌ Ansible playbook failed. Aborting..."
  exit 1
fi

echo "✅ Ansible playbook ran successfully. Proceeding to optional cleanup..."
# 🧹 Ask for cleanup
read -p "🧹 Do you want to clean up temporary resources? (y/n): " DO_CLEANUP
if [[ "$DO_CLEANUP" =~ ^[Yy]$ ]]; then
  echo "🔻 Removing NSG rules and temp IP..."
  az network nsg rule delete --resource-group rg-avd-lab --nsg-name nsg-avd --name Allow-RDP-Temp || true
  az network nsg rule delete --resource-group rg-avd-lab --nsg-name nsg-avd --name Allow-WinRM-Temp || true

  az network nic ip-config update \
    --name ipconfig1 \
    --nic-name nic-avd \
    --resource-group rg-avd-lab \
    --remove publicIpAddress || true

  az network public-ip delete \
    --name ip-temp-ansible \
    --resource-group rg-avd-lab || true

  echo "✅ Cleanup completed."
else
  echo "⏳ Temporary resources were not deleted. Remember to clean up manually later."
fi
