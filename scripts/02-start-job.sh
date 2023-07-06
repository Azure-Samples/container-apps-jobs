#!/bin/bash

# Variables
source ./00-variables.sh

# Print the menu
echo "===================================="
echo "Start Azure Container App Job (1-7): "
echo "===================================="
options=(
  "Bicep Sender Job"
  "Bicep Processor Job"
  "Bicep Receiver Job"
  "Azure CLI Sender Job"
  "Azure CLI Processor Job"
  "Azure CLI Receiver Job"
  "Quit"
)
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

# Start job
echo "Starting the [$name] job..."
az containerapp job start --name $name --resource-group $resourceGroupName
if [[ $? == 0 ]]; then
  echo "[$name] job successfully started"
else
  echo "Failed to start the [$name] job"
fi