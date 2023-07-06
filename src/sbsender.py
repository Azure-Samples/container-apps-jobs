#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) 2023 Paolo Salvatori
# Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

import os
import asyncio
import random
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from azure.identity.aio import DefaultAzureCredential
from dotenv import load_dotenv
from dotenv import dotenv_values

# Load environment variables from .env file
if os.path.exists(".env"):
  load_dotenv(override = True)
  config = dotenv_values(".env")

# Read environment variables
fully_qualified_namespace = os.getenv("FULLY_QUALIFIED_NAMESPACE")
queue_name = os.getenv("INPUT_QUEUE_NAME")
min_number = int(os.getenv("MIN_NUMBER", 1))
max_number = int(os.getenv("MAX_NUMBER", 10))
message_count = int(os.getenv("MESSAGE_COUNT", 100))
send_type = os.getenv("SEND_TYPE", "list")

# Print environment variables
print(f"FULLY_QUALIFIED_NAMESPACE: {fully_qualified_namespace}")
print(f"INPUT_QUEUE_NAME: {queue_name}")
print(f"MIN_NUMBER: {min_number}")
print(f"MAX_NUMBER: {max_number}")
print(f"MESSAGE_COUNT: {message_count}")
print(f"SEND_TYPE: {send_type}")

# Get credential object
credential = DefaultAzureCredential()

async def send_a_list_of_messages(sender):
  try:
    # Create a list of messages and send it to the queue
    messages = [ServiceBusMessage(f"{random.randint(min_number, max_number)}") for _ in range(message_count)]
    await sender.send_messages(messages)
    print(f"Sent a list of {message_count} messages to the {queue_name} queue")
  except Exception as e:
    print(f"An error occurred while sending a list of message to the {queue_name} queue: {e}")

async def send_batch_message(sender):
  # Create a batch of messages
  async with sender:
    batch_message = await sender.create_message_batch()
    for _ in range(message_count):
      try:
        # Add a message to the batch
        batch_message.add_message(ServiceBusMessage(f"{random.randint(min_number, max_number)}"))
      except Exception as e:
        print(f"An error occurred while creating a batch of messages: {e}")
        break
    # Send the batch of messages to the queue
    try:
      await sender.send_messages(batch_message)
      print(f"Sent a batch of {message_count} messages to the {queue_name} queue")
    except Exception as e:
      print(f"An error occurred while sending a batch of message to the {queue_name} queue: {e}")
  
async def run():
  # create a Service Bus client using the credential
  async with ServiceBusClient(
    fully_qualified_namespace = fully_qualified_namespace,
    credential = credential,
    logging_enable = False) as servicebus_client:
    # get a Queue Sender object to send messages to the queue
    sender = servicebus_client.get_queue_sender(queue_name = queue_name)
    async with sender:
      if send_type ==  "list":
        await send_a_list_of_messages(sender)
      elif send_type ==  "batch":
        await send_batch_message(sender)
      else:
        print(f"Invalid send type: {send_type}")

# Send messages to the input queue
asyncio.run(run())

# Close credential object when it's no longer needed
asyncio.run(credential.close())