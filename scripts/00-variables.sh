# Variables
prefix="Gundam"
name="${prefix}Receiver"
managedIdentityName="${prefix}JobManagedIdentity"
serviceBusNamespace="${prefix}ServiceBus"
resourceGroupName="${prefix}RG"
environmentName="${prefix}Environment"
imageName="paolosalvatori.azurecr.io/sbsender:v1"
acrName="${prefix}Acr"
replicaTimeout=300
replicaRetryLimit=1
cpu="0.25"
memory="0.5Gi"

# Queues
inputQueueName="input"
outputQueueName="output"

# Sender Job
senderJobName="${prefix,,}azcliSender"
senderJobTriggerType="Manual"
senderJobReplicaCompletionCount=1
senderJobParallelism=1
senderJobImageName="sbsender"
senderJobImageTag="v1"
senderJobMinNumber=1
senderJobMaxNumber=10
senderJobMessageCount=100
senderJobSendType="list"

# Processor Job
processorJobName="${prefix,,}azcliprocessor"
processorJobTriggerType="Schedule"
processorJobReplicaCompletionCount=5
processorJobParallelism=5
processorJobCronExpression="*/5 * * * *"
processorJobImageName="sbprocessor"
processorJobImageTag="v1"
processorMaxMessageCount=20
processorMaxWaitTime=5

# Receiver Job
receiverJobName="${prefix,,}azclireceiver"
receiverJobTriggerType="Event"
receiverJobReplicaCompletionCount=5
receiverJobParallelism=5
receiverJobImageName="sbreceiver"
receiverJobImageTag="v1"
receiverMinExecutions=1
receiverMaxExecutions=10
receiverMaxMessageCount=20
receiverMaxWaitTime=5
receiverMessageCount=5

# Bicep generated entities
bicepSenderJobName="${prefix,,}sender"
bicepProcessorJobName="${prefix,,}processor"
bicepReceiverJobName="${prefix,,}receiver"