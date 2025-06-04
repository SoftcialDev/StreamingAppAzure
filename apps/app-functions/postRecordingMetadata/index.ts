import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { DefaultAzureCredential } from "@azure/identity";
import { CosmosClient } from "@azure/cosmos";

interface MetadataRequest {
  user: string;
  recordingUrl: string;
  durationSec: number;
  timestampStart: number;
}

/**
 * HTTP-triggered function that saves recording metadata to Cosmos DB.
 * Expects JSON body with user, recordingUrl, durationSec, timestampStart.
 */
const httpTrigger: AzureFunction = async (
  context: Context,
  req: HttpRequest
): Promise<void> => {
  const body = req.body as MetadataRequest;
  if (
    !body ||
    typeof body.user !== "string" ||
    typeof body.recordingUrl !== "string" ||
    typeof body.durationSec !== "number" ||
    typeof body.timestampStart !== "number"
  ) {
    context.res = {
      status: 400,
      body: { error: "Invalid payload. Expect user, recordingUrl, durationSec, timestampStart." }
    };
    return;
  }

  try {
    const accountName = process.env["COSMOSDB_ACCOUNT_NAME"]!;
    const databaseName = process.env["COSMOSDB_DATABASE_NAME"]!;
    const containerName = process.env["COSMOSDB_CONTAINER_NAME"]!;
    const endpoint = `https://${accountName}.documents.azure.com:443/`;
    const credential = new DefaultAzureCredential();
    const client = new CosmosClient({ endpoint, aadCredentials: credential });

    const database = client.database(databaseName);
    const container = database.container(containerName);

    const document = {
      id: `${body.user}-${body.timestampStart}`,
      user: body.user,
      recordingUrl: body.recordingUrl,
      durationSec: body.durationSec,
      timestampStart: body.timestampStart
    };

    await container.items.create(document);
    context.log.verbose(`Saved metadata for user=${body.user}`);

    context.res = {
      status: 200,
      body: { result: "Metadata saved successfully." }
    };
  } catch (error) {
    context.log.error("Error saving metadata:", error);
    context.res = {
      status: 500,
      body: { error: "Failed to save metadata." }
    };
  }
};

export default httpTrigger;
