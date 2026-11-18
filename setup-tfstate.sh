#!/bin/bash

# ============================================================
# Azure Storage para Terraform Remote State
# ============================================================

# Variáveis
RESOURCE_GROUP="rg-tfstate"
STORAGE_ACCOUNT="tfstatecurso$RANDOM"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

echo "======================================"
echo "VARIAVEIS"
echo "======================================"

echo "RESOURCE_GROUP=$RESOURCE_GROUP"
echo "STORAGE_ACCOUNT=$STORAGE_ACCOUNT"
echo "CONTAINER_NAME=$CONTAINER_NAME"
echo "LOCATION=$LOCATION"

echo
echo "======================================"
echo "CRIANDO RESOURCE GROUP"
echo "======================================"

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo
echo "======================================"
echo "CRIANDO STORAGE ACCOUNT"
echo "======================================"

az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --encryption-services blob

echo
echo "======================================"
echo "OBTENDO ACCOUNT KEY"
echo "======================================"

ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RESOURCE_GROUP" \
  --account-name "$STORAGE_ACCOUNT" \
  --query '[0].value' \
  --output tsv)

echo "Account Key obtida com sucesso."

echo
echo "======================================"
echo "CRIANDO CONTAINER COM ACCOUNT KEY"
echo "======================================"

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY"

echo
echo "======================================"
echo "CRIANDO/VALIDANDO CONTAINER COM LOGIN AZURE"
echo "======================================"

az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login

echo
echo "======================================"
echo "LISTANDO CONTAINERS"
echo "======================================"

az storage container list \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output table

echo
echo "======================================"
echo "INFORMACOES FINAIS"
echo "======================================"

echo "Resource Group:"
echo "$RESOURCE_GROUP"

echo
echo "Storage Account:"
echo "$STORAGE_ACCOUNT"

echo
echo "Container:"
echo "$CONTAINER_NAME"

echo
echo "======================================"
echo "CRIANDO backend.tf"
echo "======================================"

cat > backend.tf <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}
EOF

echo
echo "backend.tf criado:"
cat backend.tf

echo
echo "======================================"
echo "TERRAFORM INIT"
echo "======================================"

terraform init