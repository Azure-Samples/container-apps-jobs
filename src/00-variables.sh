# Variables
prefix="Gundam"
acrName="${prefix}Acr"
acrResourceGrougName="${prefix}RG"
location="northeurope"
attachAcr=false
senderImageName="sbsender"
processorImageName="sbprocessor"
receiverImageName="sbreceiver"
images=($senderImageName $processorImageName $receiverImageName)
filenames=(sbsender.py sbprocessor.py sbreceiver.py)
tag="v1"

# Azure Subscription and Tenant
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)
