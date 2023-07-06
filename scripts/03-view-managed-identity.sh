#!/bin/bash

# For more information on Azure Container App Managed Identity, see:
# - https://learn.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cpython
# - https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull?tabs=azure-cli&pivots=azure-portal
# - https://azuresdkdocs.blob.core.windows.net/$web/dotnet/Azure.Identity/1.0.0/api/index.html
# - https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identities-status
# - https://pypi.org/project/azure-identity/

# Variables
source ./00-variables.sh

# Print the menu
echo "========================================================"
echo "View Managed Identity for Azure Container App Job (1-7): "
echo "========================================================"
options=("Bicep Sender Job"
  "Bicep Processor Job"
  "Bicep Receiver Job"
  "Azure CLI Sender Job"
  "Azure CLI Processor Job"
  "Azure CLI Receiver Job"
"Quit")
name=""
# Select an option
COLUMNS=0
select option in "${options[@]}"; do
  case $option in
    "Bicep Sender Job")
      name=$bicepSenderJobName
      break
    ;;
    "Bicep Processor Job")
      name=$bicepProcessorJobName
      break
    ;;
    "Bicep Receiver Job")
      name=$bicepReceiverJobName
      break
    ;;
    "Azure CLI Sender Job")
      name=$senderJobName
      break
    ;;
    "Azure CLI Processor Job")
      name=$processorJobName
      break
    ;;
    "Azure CLI Receiver Job")
      name=$receiverJobName
      break
    ;;
    "Quit")
      exit
    ;;
    *) echo "invalid option $REPLY" ;;
  esac
done

# View Azure Containers App Job Managed Identity
echo "Viewing the [$name] job managed identity..."
az containerapp job identity show --name $name -g $resourceGroupName