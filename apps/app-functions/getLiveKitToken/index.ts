import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { getSecretValue } from "../shared/keyVaultClient";
import { AccessToken } from "livekit-server-sdk";

const httpTrigger: AzureFunction = async (
  context: Context,
  req: HttpRequest
): Promise<void> => {
  const user = (req.query.user || (req.body && req.body.user)) as string;
  if (!user) {
    context.res = {
      status: 400,
      body: { error: "Query parameter 'user' is required." }
    };
    return;
  }

  try {
    const apiKeySecretName = process.env["LIVEKIT_API_KEY_SECRET_NAME"]!;
    const apiSecretName = process.env["LIVEKIT_API_SECRET_NAME"]!;
    const livekitUrl = process.env["LIVEKIT_URL"]!;

    const apiKey = await getSecretValue(apiKeySecretName);
    const apiSecret = await getSecretValue(apiSecretName);

    const tokenBuilder = new AccessToken(apiKey, apiSecret, {
      identity: user,
      grants: { roomJoin: true }
    });

    const jwt = tokenBuilder.toJwt();
    context.log.verbose(`Generated LiveKit token for user=${user}`);

    context.res = {
      status: 200,
      body: { token: jwt, url: livekitUrl }
    };
  } catch (error) {
    context.log.error("Error generating LiveKit token:", error);
    context.res = {
      status: 500,
      body: { error: "Failed to generate LiveKit token." }
    };
  }
};

export default httpTrigger;
