import jwt from "jsonwebtoken";
import { TokenClaims } from "./types";
import { ConfidentialClientApplication, SilentFlowRequest, AuthenticationResult } from "@azure/msal-node";
import { msalNodeConfig } from "./msalConfig";

/**
 * Decodes a JWT token without verifying its signature.
 * @param token - The JWT token to decode.
 * @returns The decoded token claims, or null if the token is invalid or malformed.
 */
export function decodeToken(token: string): TokenClaims | null {
  return jwt.decode(token) as TokenClaims | null;
}

/**
 * Checks if a JWT token is expired.
 * If the token is malformed or 'exp' is missing, it is treated as expired for safety.
 * @param token - The JWT token to check.
 * @returns True if the token is expired or invalid, false otherwise.
 */
export function isTokenExpired(token: string): boolean {
  const decoded = decodeToken(token);
  const currentTime = Math.floor(Date.now() / 1000);
  // Treat malformed tokens or tokens without 'exp' as expired (secure default)
  return !decoded || typeof decoded.exp !== "number" || decoded.exp < currentTime;
}

/**
 * Renews the access token silently using MSAL Node.
 * @param account - The account object obtained after initial authentication.
 * @param scopes - An array of scopes for which the token is requested.
 * @returns A promise that resolves to the renewed access token.
 * @throws Error if token renewal fails.
 */
export async function renewToken(account: any, scopes: string[]): Promise<string> {
  const msalInstance = new ConfidentialClientApplication(msalNodeConfig);

  const silentRequest: SilentFlowRequest = {
    account,
    scopes,
  };

  try {
    const response: AuthenticationResult | null = await msalInstance.acquireTokenSilent(silentRequest);
    if (!response) {
      throw new Error("Unable to renew access token: response is null");
    }
    return response.accessToken;
  } catch (error) {
    console.error("Token renewal failed:", error);
    throw new Error("Unable to renew access token");
  }
}
