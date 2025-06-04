import { Configuration as NodeConfiguration } from "@azure/msal-node";
import { Configuration as BrowserConfiguration } from "@azure/msal-browser";

/**
 * MSAL configuration for Node.js environments (Electron, backend services).
 */
export const msalNodeConfig: NodeConfiguration = {
  auth: {
    clientId: process.env.MSAL_CLIENT_ID!,
    authority: `https://login.microsoftonline.com/${process.env.MSAL_TENANT_ID}`,
    clientSecret: process.env.MSAL_CLIENT_SECRET!,
  },
  system: {
    loggerOptions: {
      loggerCallback(loglevel, message, containsPii) {
        if (containsPii) return;
        console.log(message);
      },
      piiLoggingEnabled: false,
      logLevel: 2, // Info
    },
  },
};

/**
 * MSAL configuration for browser environments (React SPA).
 */
export const msalBrowserConfig: BrowserConfiguration = {
  auth: {
    clientId: process.env.MSAL_CLIENT_ID!,
    authority: `https://login.microsoftonline.com/${process.env.MSAL_TENANT_ID}`,
    redirectUri: process.env.MSAL_REDIRECT_URI!,
  },
  cache: {
    cacheLocation: "localStorage",
    storeAuthStateInCookie: false,
  },
};
