#!/bin/bash

# Variables
source ./00-variables.sh

# Print the menu
echo "===================================="
echo "Run Docker Container (1-4): "
echo "===================================="
options=(
  "Sender"
  "Processor"
  "Receiver"
  "Quit"
)
name=""
# Select an option
COLUMNS=0
select option in "${options[@]}"; do
  case $option in
    "Sender")
      docker run -it \
      --rm \
      --env-file .env \
      --env-file .local \
      --name $senderImageName \
      $senderImageName:$tag
      break
    ;;
    "Processor")
      docker run -it \
      --rm \
      --env-file .env \
      --env-file .local \
      --name $processorImageName \
      $processorImageName:$tag
      break
    ;;
    "Receiver")
      docker run -it \
      --rm \
      --env-file .env \
      --env-file .local \
      --name $receiverImageName \
      $receiverImageName:$tag
      break
    ;;
    "Quit")
      exit
    ;;
    *) echo "invalid option $REPLY" ;;
  esac
done