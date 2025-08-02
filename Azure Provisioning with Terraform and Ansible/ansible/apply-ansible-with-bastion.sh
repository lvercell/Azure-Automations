#!/bin/bash

# === CONFIGURACIÓN INICIAL ===
RESOURCE_GROUP="rg-avd-lab"
VM_NAME="vm-avd-lab"
NIC_NAME="nic-avd"
NSG_NAME="nsg-avd"
LOCATION="eastus"
VNET_NAME="vnet-avd"
SUBNET_NAME="subnet-avd"
BASTION_SUBNET_NAME="AzureBastionSubnet"
BASTION_NAME="bastion-avd"
ANSIBLE_DIR="./ansible"
PUBLIC_IP_NAME="ip-temp-ansible"
PUBLIC_IP_FILE="$ANSIBLE_DIR/ip-temp.txt"
HOSTS_FILE="$ANSIBLE_DIR/hosts.ini"
DOMAIN_NAME="lucasvlabs.site"
ADMIN_USER="lucas"

# === DETECTAR IP PÚBLICA LOCAL ===
MY_IP=$(curl -s ifconfig.me)
echo "🔎 Detected your public IP: $MY_IP"

# === VERIFICAR QUE LA VM EXISTE ===
VM_EXIST=$(az vm show --name $VM_NAME --resource-group $RESOURCE_GROUP --query "name" -o tsv 2>/dev/null)
if [[ -z "$VM_EXIST" ]]; then
  echo "❌ ERROR: VM '$VM_NAME' not found in resource group '$RESOURCE_GROUP'. Exiting..."
  exit 1
fi

# === VERIFICAR EXISTENCIA DE IP PÚBLICA ===
IP_EXISTS=$(az network public-ip show --name $PUBLIC_IP_NAME --resource-group $RESOURCE_GROUP --query "ipAddress" -o tsv 2>/dev/null)
if [[ -z "$IP_EXISTS" ]]; then
  echo "🌐 Creating temporary public IP..."
  az network public-ip create \
    --name $PUBLIC_IP_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku Standard \
    --allocation-method Static \
    --location $LOCATION
  IP_EXISTS=$(az network public-ip show --name $PUBLIC_IP_NAME --resource-group $RESOURCE_GROUP --query "ipAddress" -o tsv)
else
  echo "✅ Reusing existing public IP: $IP_EXISTS"
fi

echo "$IP_EXISTS" > "$PUBLIC_IP_FILE"

# === ASOCIAR IP A NIC (si no está asociada) ===
NIC_IP_ID=$(az network nic show --name $NIC_NAME --resource-group $RESOURCE_GROUP --query "ipConfigurations[0].publicIpAddress.id" -o tsv 2>/dev/null)
if [[ -z "$NIC_IP_ID" ]]; then
  echo "🔗 Associating public IP to NIC..."
  az network nic ip-config update \
    --name ipconfig1 \
    --nic-name $NIC_NAME \
    --resource-group $RESOURCE_GROUP \
    --public-ip-address $PUBLIC_IP_NAME
else
  echo "✅ NIC already has a public IP."
fi

# === ABRIR PUERTOS TEMPORALES PARA TU IP ===
echo "🔐 Adding NSG rules for WinRM and RDP (scoped to your IP only)..."
az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name Allow-RDP-Temp --priority 3001 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes $MY_IP --destination-port-ranges 3389 --destination-address-prefixes "*" --source-port-ranges "*"

az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME \
  --name Allow-WinRM-Temp --priority 3002 --access Allow --direction Inbound \
  --protocol Tcp --source-address-prefixes $MY_IP --destination-port-ranges 5986 --destination-address-prefixes "*" --source-port-ranges "*"

# === GENERAR HOSTS.INI CON IP ASOCIADA ===
echo "[windows]" > "$HOSTS_FILE"
echo "$IP_EXISTS ansible_user=$ADMIN_USER ansible_password='@Lucas2024' ansible_connection=winrm ansible_winrm_transport=basic ansible_winrm_server_cert_validation=ignore" >> "$HOSTS_FILE"

# === EJECUTAR ANSIBLE SOLO SI LA VM NO ESTÁ UNIDA A DOMINIO ===
echo "🔍 Checking if VM is joined to domain..."
JOINED=$(az vm run-command invoke --resource-group $RESOURCE_GROUP --name $VM_NAME --command-id RunPowerShellScript --scripts "((Get-WmiObject Win32_ComputerSystem).PartOfDomain).ToString()" --query "value[0].message" -o tsv 2>/dev/null)

if [[ "$JOINED" == "True" ]]; then
  echo "✅ VM is already domain-joined. Skipping join step..."
else
  echo "🔄 Running domain join + hardening playbooks..."
  cd $ANSIBLE_DIR
  ansible-playbook playbook.yml
  cd -
fi

# === DESASOCIAR IP Y BORRARLA SI FUE CREADA POR ESTE SCRIPT ===
echo "🧹 Cleaning up IP and NSG rules..."
az network nic ip-config update \
  --name ipconfig1 --nic-name $NIC_NAME \
  --resource-group $RESOURCE_GROUP \
  --remove publicIpAddress

az network nsg rule delete --name Allow-WinRM-Temp --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME
az network nsg rule delete --name Allow-RDP-Temp --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME

# === BORRAR IP TEMPORAL (opcional) ===
az network public-ip delete --name $PUBLIC_IP_NAME --resource-group $RESOURCE_GROUP

# === CREAR BASTION (si no existe) ===
echo "🚪 Ensuring Bastion exists..."
BASTION_EXISTS=$(az network bastion show --name $BASTION_NAME --resource-group $RESOURCE_GROUP --query "name" -o tsv 2>/dev/null)
if [[ -z "$BASTION_EXISTS" ]]; then
  echo "📦 Creating Bastion host..."
  az network vnet subnet create --name $BASTION_SUBNET_NAME \
    --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME \
    --address-prefixes "10.0.255.0/27"

  az network bastion create --name $BASTION_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --vnet-name $VNET_NAME \
    --public-ip-address $PUBLIC_IP_NAME
else
  echo "✅ Bastion already exists."
fi

echo "✅ Script completed. Bastion is available for secure connection."
