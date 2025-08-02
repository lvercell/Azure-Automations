#!/bin/bash

# CONFIGURACIÓN INICIAL
RESOURCE_GROUP="rg-avd-lab"
VM_NAME="vm-avd-lab"
NIC_NAME="nic-avd"
NSG_NAME="nsg-avd"
LOCATION="eastus"
VNET_NAME="vnet-avd"
SUBNET_NAME="subnet-avd"
BASTION_SUBNET_NAME="AzureBastionSubnet"
BASTION_NAME="bastion-avd"
BASTION_IP_NAME="bastion-ip"
TEMP_IP_NAME="ip-temp-ansible"

# Obtener la IP pública de la notebook para las reglas NSG
MY_IP=$(curl -s ifconfig.me)
echo "🌐 Tu IP pública detectada: $MY_IP"

echo "📡 Creando IP pública temporal..."
az network public-ip create --resource-group "$RESOURCE_GROUP" --name "$TEMP_IP_NAME" --sku "Standard"   --allocation-method Static --location "$LOCATION"

echo "🔗 Asociando IP pública temporal a la NIC de la VM..."
az network nic ip-config update   --name ipconfig1   --nic-name "$NIC_NAME"   --resource-group "$RESOURCE_GROUP"   --public-ip-address "$TEMP_IP_NAME"

echo "🔐 Agregando reglas NSG temporales para RDP (3389) y WinRM (5986)..."
az network nsg rule create --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME"   --name Allow-RDP-Temp --priority 3001   --source-address-prefixes "$MY_IP" --destination-port-ranges 3389   --access Allow --protocol Tcp --direction Inbound

az network nsg rule create --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME"   --name Allow-WinRM-Temp --priority 3002   --source-address-prefixes "$MY_IP" --destination-port-ranges 5986   --access Allow --protocol Tcp --direction Inbound

echo "💾 Detectando IP pública REAL asociada a la NIC..."
REAL_VM_IP=$(az network public-ip show --ids $(az network nic show   --name "$NIC_NAME"   --resource-group "$RESOURCE_GROUP"   --query "ipConfigurations[0].publicIpAddress.id" -o tsv)   --query ipAddress -o tsv)

echo "🧾 Usando IP pública real: $REAL_VM_IP"

echo "[windows]" > ./hosts.ini
echo "$REAL_VM_IP" >> ./hosts.ini
cat <<EOF >> ./hosts.ini

[windows:vars]
ansible_user=lucas
ansible_password='@Lucas2024'
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
EOF

echo "🔍 Verificando si Ansible está instalado..."
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Error: ansible-playbook no está disponible. Instalalo con: pip install ansible"
    exit 1
fi

echo "🔄 Ejecutando playbook principal con main.yml..."
ansible-playbook main.yml -i hosts.ini -vv

echo "🧹 Limpiando reglas NSG y IP pública temporal..."
az network nsg rule delete --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" --name Allow-RDP-Temp
az network nsg rule delete --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_NAME" --name Allow-WinRM-Temp
az network nic ip-config update --name ipconfig1 --nic-name "$NIC_NAME" --resource-group "$RESOURCE_GROUP" --remove publicIpAddress
az network public-ip delete --name "$TEMP_IP_NAME" --resource-group "$RESOURCE_GROUP"

echo "✅ Proceso finalizado."
