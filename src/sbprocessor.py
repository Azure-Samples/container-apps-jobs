#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) 2023 Paolo Salvatori
# Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

import os
import asyncio
from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage
from azure.identity.aio import DefaultAzureCredential
from dotenv import load_dotenv
from dotenv import dotenv_values

# Load environment variables from .env file
if os.path.exists(".env"):
  load_dotenv(override=True)
  config = dotenv_values(".env")

# Read environment variables
fully_qualified_namespace = os.getenv("FULLY_QUALIFIED_NAMESPACE")
input_queue_name = os.getenv("INPUT_QUEUE_NAME")
output_queue_name = os.getenv("OUTPUT_QUEUE_NAME")
max_message_count = int(os.getenv("MAX_MESSAGE_COUNT", 20))
max_wait_time = int(os.getenv("MAX_WAIT_TIME", 5))

# Print environment variables
print(f"FULLY_QUALIFIED_NAMESPACE: {fully_qualified_namespace}")
print(f"INPUT_QUEUE_NAME: {input_queue_name}")
print(f"OUTPUT_QUEUE_NAME: {output_queue_name}")
print(f"MAX_MESSAGE_COUNT: {max_message_count}")
print(f"MAX_WAIT_TIME: {max_wait_time}")

# Get credential object
credential = DefaultAzureCredential()

async def fibonacci(n):
  if n <= 0:
    raise ValueError("n must be a positive integer")
  elif n == 1:
    return 0
  elif n == 2:
    return 1
  else:
    fib1 = await fibonacci(n - 1)
    fib2 = await fibonacci(n - 2)
    return fib1 + fib2

async def send_message(message_text: str, i: int):
   # Check that the message is not empty
  if message_text:
    try:
      # Create a Service Bus client using the credential
      async with ServiceBusClient(
        fully_qualified_namespace = fully_qualified_namespace,
        credential = credential,
        logging_enable = True) as servicebus_client:
        # Get a Queue Sender object to send messages to the output queue
        sender = servicebus_client.get_queue_sender(queue_name = output_queue_name)
        async with sender:
          # Create a Service Bus message and send it to the queue
          message = ServiceBusMessage(message_text)
          # Send a message to the output queue
          await sender.send_messages(message)
          print(f"[{i}] Sent result message: {message_text}")
    except Exception as e:
      print(f"An error occurred while sending [{i}] message to the {output_queue_name} queue: {e}")
  else:
    print(f"The [{i}] message is empty. Please, enter a valid message.")

async def receive_messages():
  # create a Service Bus client using the connection string
  async with ServiceBusClient(
    fully_qualified_namespace = fully_qualified_namespace,
    credential = credential,
    logging_enable = False) as servicebus_client:

    async with servicebus_client:
      # Get the Queue Receiver object for the input queue
      receiver = servicebus_client.get_queue_receiver(queue_name = input_queue_name)
      async with receiver:
        try:
          received_msgs = await receiver.receive_messages(max_wait_time = max_wait_time, max_message_count = max_message_count)
          i = 0
          for msg in received_msgs:
            # Check if message contains an integer value
            try:
              n = int(str(msg))
              i += 1
              print(f"[{i}] Received Message: {n}")
              # Calculate Fibonacci number
              result = await fibonacci(n)
              print(f"[{i}] The Fibonacci number for {n} is {result}")
              # Send result to the output queue
              await send_message(str(result), i)
            except ValueError:
              print(f"[{i}] Received message {str(msg)} is not an integer number")
              continue
            finally:
              # Complete the message so that the message is removed from the queue
              await receiver.complete_message(msg)
              print(f"[{i}] Completed message: {str(msg)}")
        except Exception as e:
          print(f"An error occurred while receiving messages from the {input_queue_name} queue: {e}")

# Receive messages from the input queue
asyncio.run(receive_messages())

# Close credential object when it's no longer needed
asyncio.run(credential.close())