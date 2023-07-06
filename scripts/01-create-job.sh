#!/bin/bash

# Variables
source ./00-variables.sh

# Print the menu
echo "====================================="
echo "Create Azure Container App Job (1-4): "
echo "====================================="
options=(
  "Sender Job"
  "Processor Job"
  "Receiver Job"
"Quit")
name=""
# Select an option
COLUMNS=0
select option in "${options[@]}"; do
  case $option in
    "Sender Job")
      # Retrieve the resource id of the user-assigned managed identity
      echo "Retrieving the resource id for the [$managedIdentityName] managed identity..."
      managedIdentityId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query id \
        --output tsv)

      if [[ -n $managedIdentityId ]]; then
        echo "[$managedIdentityId] resource id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the resource id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the client id of the user-assigned managed identity
      echo "Retrieving the client id for the [$managedIdentityName] managed identity..."
      clientId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query clientId \
        --output tsv)

      if [[ -n $clientId ]]; then
        echo "[$clientId] client id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the client id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the ACR loginServer
      echo "Retrieving the loginServer for the [$acrName] container registry..."
      loginServer=$(az acr show \
        --name $acrName \
        --resource-group $resourceGroupName \
        --query loginServer \
        --output tsv)

      if [[ -n $loginServer ]]; then
        echo "[$loginServer] loginServer for the [$acrName] container registry successfully retrieved"
      else
        echo "Failed to retrieve the loginServer for the [$acrName] container registry"
        exit
      fi

      # Create the sender job
      echo "Retrieving the [${senderJobName,,}] job..."
      az containerapp job show \
          --name ${senderJobName,,} \
          --resource-group $resourceGroupName &>/dev/null
      if [[ $? != 0 ]]; then
        echo "No [${senderJobName,,}] job actually exists in the [$environmentName] environment"
        echo "Creating [${senderJobName,,}] job in the [$environmentName] environment..."
        az containerapp job create \
          --name ${senderJobName,,} \
          --resource-group $resourceGroupName \
          --environment $environmentName \
          --trigger-type $senderJobTriggerType \
          --replica-timeout $replicaTimeout \
          --replica-retry-limit $replicaRetryLimit \
          --replica-completion-count $senderJobReplicaCompletionCount \
          --parallelism $senderJobParallelism \
          --image "${loginServer}/${senderJobImageName}:${senderJobImageTag}" \
          --cpu $cpu \
          --memory $memory \
          --registry-identity $managedIdentityId \
          --registry-server $loginServer \
          --env-vars \
              AZURE_CLIENT_ID=$clientId \
              FULLY_QUALIFIED_NAMESPACE="${serviceBusNamespace}.servicebus.windows.net" \
              INPUT_QUEUE_NAME=$inputQueueName \
              MIN_NUMBER="$senderJobMinNumber" \
              MAX_NUMBER="$senderJobMaxNumber" \
              MESSAGE_COUNT="$senderJobMessageCount" \
              SEND_TYPE="$senderJobSendType" 1>/dev/null
          if [[ $? == 0 ]]; then
            echo "[$environmentName] environment successfully created in the [$subscriptionName] subscription"
          else
            echo "Failed to create [$environmentName] environment in the [$subscriptionName] subscription"
            exit
          fi
      else
        echo "[$environmentName] environment already contains a [${senderJobName,,}] job"
      fi
      break
      ;;
    "Processor Job")
      # Retrieve the resource id of the user-assigned managed identity
      echo "Retrieving the resource id for the [$managedIdentityName] managed identity..."
      managedIdentityId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query id \
        --output tsv)

      if [[ -n $managedIdentityId ]]; then
        echo "[$managedIdentityId] resource id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the resource id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the client id of the user-assigned managed identity
      echo "Retrieving the client id for the [$managedIdentityName] managed identity..."
      clientId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query clientId \
        --output tsv)

      if [[ -n $clientId ]]; then
        echo "[$clientId] client id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the client id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the ACR loginServer
      echo "Retrieving the loginServer for the [$acrName] container registry..."
      loginServer=$(az acr show \
        --name $acrName \
        --resource-group $resourceGroupName \
        --query loginServer \
        --output tsv)

      if [[ -n $loginServer ]]; then
        echo "[$loginServer] loginServer for the [$acrName] container registry successfully retrieved"
      else
        echo "Failed to retrieve the loginServer for the [$acrName] container registry"
        exit
      fi

      # Create the processor job
      echo "Retrieving the [${processorJobName,,}] job..."
      az containerapp job show \
          --name ${processorJobName,,} \
          --resource-group $resourceGroupName &>/dev/null
      if [[ $? != 0 ]]; then
        echo "No [${processorJobName,,}] job actually exists in the [$environmentName] environment"
        echo "Creating [${processorJobName,,}] job in the [$environmentName] environment..."
        az containerapp job create \
          --name ${processorJobName,,} \
          --resource-group $resourceGroupName \
          --environment $environmentName \
          --trigger-type $processorJobTriggerType \
          --replica-timeout $replicaTimeout \
          --replica-retry-limit $replicaRetryLimit \
          --replica-completion-count $processorJobReplicaCompletionCount \
          --parallelism $processorJobParallelism \
          --cron-expression "$processorJobCronExpression" \
          --image "${loginServer}/${processorJobImageName}:${processorJobImageTag}" \
          --cpu $cpu \
          --memory $memory \
          --registry-identity $managedIdentityId \
          --registry-server $loginServer \
          --env-vars \
              AZURE_CLIENT_ID=$clientId \
              FULLY_QUALIFIED_NAMESPACE="${serviceBusNamespace}.servicebus.windows.net" \
              INPUT_QUEUE_NAME=$inputQueueName \
              OUTPUT_QUEUE_NAME=$outputQueueName \
              MAX_MESSAGE_COUNT="$processorMaxMessageCount" \
              MAX_WAIT_TIME="$processorMaxWaitTime" 1>/dev/null
          if [[ $? == 0 ]]; then
            echo "[$environmentName] environment successfully created in the [$subscriptionName] subscription"
          else
            echo "Failed to create [$environmentName] environment in the [$subscriptionName] subscription"
            exit
          fi
      else
        echo "[$environmentName] environment already contains a [${processorJobName,,}] job"
      fi
      break
    ;;
    "Receiver Job")
      # Retrieve the resource id of the user-assigned managed identity
      echo "Retrieving the resource id for the [$managedIdentityName] managed identity..."
      managedIdentityId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query id \
        --output tsv)

      if [[ -n $managedIdentityId ]]; then
        echo "[$managedIdentityId] resource id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the resource id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the client id of the user-assigned managed identity
      echo "Retrieving the client id for the [$managedIdentityName] managed identity..."
      clientId=$(az identity show \
        --name $managedIdentityName \
        --resource-group $resourceGroupName \
        --query clientId \
        --output tsv)

      if [[ -n $clientId ]]; then
        echo "[$clientId] client id for the [$managedIdentityName] managed identity successfully retrieved"
      else
        echo "Failed to retrieve the client id for the [$managedIdentityName] managed identity"
        exit
      fi

      # Retrieve the ACR loginServer
      echo "Retrieving the loginServer for the [$acrName] container registry..."
      loginServer=$(az acr show \
        --name $acrName \
        --resource-group $resourceGroupName \
        --query loginServer \
        --output tsv)

      if [[ -n $loginServer ]]; then
        echo "[$loginServer] loginServer for the [$acrName] container registry successfully retrieved"
      else
        echo "Failed to retrieve the loginServer for the [$acrName] container registry"
        exit
      fi

      # Retrieve the Service Bus namespace connection string
      echo "Retrieving the connection string for the [$serviceBusNamespace] Service Bus namespace..."
      serviceBusConnectionString=$(az servicebus namespace authorization-rule keys list \
        --name RootManageSharedAccessKey \
        --namespace-name $serviceBusNamespace \
        --resource-group $resourceGroupName \
        --query primaryConnectionString \
        --output tsv)
      if [[ -n $serviceBusConnectionString ]]; then
        echo "[$serviceBusConnectionString] connection string for the [$serviceBusNamespace] Service Bus namespace successfully retrieved"
      else
        echo "Failed to retrieve the connection string for the [$serviceBusNamespace] Service Bus namespace"
        exit
      fi

      # Create the receiver job
      echo "Retrieving the [${receiverJobName,,}] job..."
      az containerapp job show \
          --name ${receiverJobName,,} \
          --resource-group $resourceGroupName &>/dev/null
      if [[ $? != 0 ]]; then
        echo "No [${receiverJobName,,}] job actually exists in the [$environmentName] environment"
        echo "Creating [${receiverJobName,,}] job in the [$environmentName] environment..."
        az containerapp job create \
          --name ${receiverJobName,,} \
          --resource-group $resourceGroupName \
          --environment $environmentName \
          --trigger-type $receiverJobTriggerType \
          --replica-timeout $replicaTimeout \
          --replica-retry-limit $replicaRetryLimit \
          --replica-completion-count $receiverJobReplicaCompletionCount \
          --parallelism $receiverJobParallelism \
          --image "${loginServer}/${receiverJobImageName}:${receiverJobImageTag}" \
          --cpu $cpu \
          --memory $memory \
          --min-executions $receiverMinExecutions \
          --max-executions $receiverMaxExecutions \
          --registry-identity $managedIdentityId \
          --registry-server $loginServer \
          --secrets service-bus-connection-string="$serviceBusConnectionString" \
          --env-vars \
              AZURE_CLIENT_ID=$clientId \
              FULLY_QUALIFIED_NAMESPACE="${serviceBusNamespace}.servicebus.windows.net" \
              OUTPUT_QUEUE_NAME=$outputQueueName \
              MAX_MESSAGE_COUNT="$receiverMaxMessageCount" \
              MAX_WAIT_TIME="$receiverMaxWaitTime" \
          --scale-rule-name azure-servicebus-queue-rule \
          --scale-rule-type azure-servicebus \
          --scale-rule-metadata "queueName=$outputQueueName" \
                              "namespace=$serviceBusNamespace" \
                              "messageCount=$receiverMessageCount" \
          --scale-rule-auth "connection=service-bus-connection-string" 1>/dev/null
          if [[ $? == 0 ]]; then
            echo "[$environmentName] environment successfully created in the [$subscriptionName] subscription"
          else
            echo "Failed to create [$environmentName] environment in the [$subscriptionName] subscription"
            exit
          fi
      else
        echo "[$environmentName] environment already contains a [${receiverJobName,,}] job"
      fi
      break
    ;;
    "Quit")
      exit
    ;;
    *) echo "invalid option $REPLY" ;;
  esac
done
