import { DefaultAzureCredential } from "@azure/identity";
import { SecretClient } from "@azure/keyvault-secrets";

/**
 * Returns a SecretClient to read secrets from Key Vault using Managed Identity.
 * KEYVAULT_URI is the base URI of the vault (e.g. https://myvault.vault.azure.net/).
 */
export function getKeyVaultClient(): SecretClient {
  const vaultUri = process.env["KEYVAULT_URI"]!;
  const credential = new DefaultAzureCredential();
  return new SecretClient(vaultUri, credential);
}

/**
 * Retrieves the value of a secret by its name.
 * @param secretName Name of the secret in Key Vault.
 * @returns The secret value.
 */
export async function getSecretValue(secretName: string): Promise<string> {
  const client = getKeyVaultClient();
  const response = await client.getSecret(secretName);
  return response.value!;
}
