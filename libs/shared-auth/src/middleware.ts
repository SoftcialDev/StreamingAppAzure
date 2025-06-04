import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { TokenClaims } from "./types";

/**
 * Represents the user data attached to the request after authentication.
 */
export interface AuthenticatedUser {
  name: string;
  email: string;
  roles: string[];
}

/**
 * Extends Express Request to optionally include the user property.
 * Used only for type assertion when accessing req.user after middleware runs.
 */
export interface UserRequest extends Request {
  user?: AuthenticatedUser;
}

/**
 * Express middleware to authenticate JWT tokens and enforce required user roles.
 * - Checks for a valid Bearer token in the Authorization header.
 * - Decodes the token and validates required claims (name, preferred_username, roles).
 * - Checks if the user has at least one of the allowed roles.
 * - Attaches the user object to the request if successful.
 * - Returns 401 if the token is missing.
 * - Returns 403 if the token is invalid, missing required claims, or the user lacks roles.
 *
 * @param allowedRoles - An array of roles allowed to access the route (e.g. ["Admin"])
 * @returns Express middleware function
 *
 * @example
 *   app.get("/secure", authenticateTokenMiddleware(["Admin"]), (req, res) => {
 *     const user = (req as UserRequest).user;
 *     res.json({ hello: user?.name });
 *   });
 */
export function authenticateTokenMiddleware(allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      res.status(401).json({ message: "Access token is missing" });
      return;
    }

    try {
      const decoded = jwt.decode(token) as TokenClaims | null;

      if (
        !decoded ||
        typeof decoded.name !== "string" ||
        typeof decoded.preferred_username !== "string" ||
        !Array.isArray(decoded.roles)
      ) {
        res.status(403).json({ message: "Required claims missing in token" });
        return;
      }

      const hasRole = decoded.roles.some((role) => allowedRoles.includes(role));
      if (!hasRole) {
        res.status(403).json({ message: "Insufficient role privileges" });
        return;
      }

      (req as UserRequest).user = {
        name: decoded.name,
        email: decoded.preferred_username,
        roles: decoded.roles,
      };

      next();
    } catch (error) {
      console.error("Token verification failed:", error);
      res.status(403).json({ message: "Token verification failed" });
    }
  };
}
