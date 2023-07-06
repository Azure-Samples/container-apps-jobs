#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) 2023 Paolo Salvatori
# Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

import os
import asyncio
from azure.servicebus.aio import ServiceBusClient
from azure.identity.aio import DefaultAzureCredential
from dotenv import load_dotenv
from dotenv import dotenv_values

# Load environment variables from .env file
if os.path.exists(".env"):
  load_dotenv(override=True)
  config = dotenv_values(".env")

# Read environment variables
fully_qualified_namespace = os.getenv("FULLY_QUALIFIED_NAMESPACE")
queue_name = os.getenv("OUTPUT_QUEUE_NAME")
max_message_count = int(os.getenv("MAX_MESSAGE_COUNT", 20))
max_wait_time = int(os.getenv("MAX_WAIT_TIME", 5))

# Print environment variables
print(f"FULLY_QUALIFIED_NAMESPACE: {fully_qualified_namespace}")
print(f"OUTPUT_QUEUE_NAME: {queue_name}")
print(f"MAX_MESSAGE_COUNT: {max_message_count}")
print(f"MAX_WAIT_TIME: {max_wait_time}")

# Get credential object
credential = DefaultAzureCredential()

async def receive_messages():
  # create a Service Bus client using the connection string
  async with ServiceBusClient(
    fully_qualified_namespace = fully_qualified_namespace,
    credential = credential,
    logging_enable = False) as servicebus_client:

    async with servicebus_client:
      # Get the Queue Receiver object for the input queue
      receiver = servicebus_client.get_queue_receiver(queue_name = queue_name)
      async with receiver:
        i = 0
        # Receive a batch of messages until the queue is empty
        while True:
          try:
            received_msgs = await receiver.receive_messages(max_wait_time = max_wait_time, max_message_count = max_message_count)
            if len(received_msgs) == 0:
              break
            for msg in received_msgs:
              # Check if message contains an integer value
              try:
                n = int(str(msg))
                i += 1
                print(f"[{i}] Received Message: {n}")
              except ValueError:
                print(f"[{i}] Received message {str(msg)} is not an integer number")
                continue
              finally:
                # Complete the message so that the message is removed from the queue
                await receiver.complete_message(msg)
                print(f"[{i}] Completed message: {str(msg)}")
          except Exception as e:
            print(f"An error occurred while receiving messages from the {queue_name} queue: {e}")
            break

# Receive messages from the input queue
asyncio.run(receive_messages())

# Close credential object when it's no longer needed
asyncio.run(credential.close())