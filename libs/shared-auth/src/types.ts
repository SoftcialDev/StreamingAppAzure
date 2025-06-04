/**
 * Represents the configuration required for authentication.
 */
export interface AuthConfig {
  clientId: string;
  tenantId: string;
  clientSecret?: string;
  redirectUri?: string;
}

/**
 * Represents the claims present in a JWT token.
 */
export interface TokenClaims {
  aud: string;
  iss: string;
  iat: number;
  nbf: number;
  exp: number;
  aio?: string;
  name?: string;
  preferred_username?: string;
  roles?: string[];
  [key: string]: any;
}

/**
 * Represents a user's profile information extracted from token claims.
 */
export interface UserProfile {
  name: string;
  email: string;
  roles: string[];
}
