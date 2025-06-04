import { DefaultAzureCredential } from "@azure/identity";
import { ServiceBusClient, ServiceBusMessage } from "@azure/service-bus";

/**
 * Returns a ServiceBusClient authenticated via Managed Identity.
 * SERVICEBUS_NAMESPACE_ID is the Resource ID of the namespace.
 */
export function getServiceBusClient(): ServiceBusClient {
  const namespaceId = process.env["SERVICEBUS_NAMESPACE_ID"]!;
  const parts = namespaceId.split("/");
  const namespaceName = parts[parts.length - 1];
  const endpoint = `https://${namespaceName}.servicebus.windows.net`;
  const credential = new DefaultAzureCredential();
  return new ServiceBusClient(endpoint, credential);
}

/**
 * Sends a JSON message to the specified queue.
 * @param queueName Name of the Service Bus queue.
 * @param messageBody JSON object to enqueue.
 * @param sessionId Optional session ID for session-enabled queues.
 */
export async function sendToQueue(
  queueName: string,
  messageBody: Record<string, unknown>,
  sessionId?: string
): Promise<void> {
  const client = getServiceBusClient();
  const sender = client.createSender(queueName);
  const message: ServiceBusMessage = {
    body: messageBody,
    contentType: "application/json",
    sessionId: sessionId
  };
  await sender.sendMessages(message);
  await sender.close();
  await client.close();
}
