import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { sendToQueue } from "../shared/serviceBusClient";

interface RecordingRequest {
  user: string;
  action: "START" | "STOP";
}

/**
 * HTTP-triggered function that enqueues a recording command to Service Bus.
 * Expects JSON body with 'user' and 'action' ("START" or "STOP").
 */
const httpTrigger: AzureFunction = async (
  context: Context,
  req: HttpRequest
): Promise<void> => {
  const body = req.body as RecordingRequest;
  if (!body || typeof body.user !== "string" || typeof body.action !== "string") {
    context.res = {
      status: 400,
      body: { error: "Request must include 'user' and 'action'." }
    };
    return;
  }

  const action = body.action.toUpperCase();
  if (action !== "START" && action !== "STOP") {
    context.res = {
      status: 400,
      body: { error: "Action must be either 'START' or 'STOP'." }
    };
    return;
  }

  const queueName = "EmployeeCommandQueue";
  try {
    await sendToQueue(queueName, { user: body.user, action }, body.user);
    context.log.verbose(`Enqueued command for user=${body.user}, action=${action}`);
    context.res = {
      status: 200,
      body: { result: "Command enqueued successfully." }
    };
  } catch (error) {
    context.log.error("Error enqueuing message:", error);
    context.res = {
      status: 500,
      body: { error: "Failed to enqueue message." }
    };
  }
};

export default httpTrigger;
