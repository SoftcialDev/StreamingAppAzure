// test/authHelpers.test.ts

import { decodeToken, isTokenExpired } from "../src/authHelpers";
import * as jwt from "jsonwebtoken";

describe("Auth Helpers", () => {
  const payload = {
    aud: "test-aud",
    iss: "test-iss",
    iat: Math.floor(Date.now() / 1000) - 60,
    exp: Math.floor(Date.now() / 1000) + 60,
    name: "Test User",
    preferred_username: "testuser@example.com",
    roles: ["Admin"],
  };

  const token = jwt.sign(payload, "test-secret");

  test("decodeToken should return correct payload", () => {
    const decoded = decodeToken(token);
    expect(decoded?.name).toBe("Test User");
    expect(decoded?.roles).toContain("Admin");
  });

  test("isTokenExpired should return false for valid token", () => {
    expect(isTokenExpired(token)).toBe(false);
  });

  test("isTokenExpired should return true for expired token", () => {
    const expiredPayload = {
      ...payload,
      exp: Math.floor(Date.now() / 1000) - 120,
    };
    const expiredToken = jwt.sign(expiredPayload, "test-secret");
    expect(isTokenExpired(expiredToken)).toBe(true);
  });

  test("decodeToken should return null for invalid token", () => {
    const decoded = decodeToken("this.is.not.a.valid.jwt");
    expect(decoded).toBeNull();
  });

  test("isTokenExpired should return true for malformed token", () => {
    expect(isTokenExpired("not.a.jwt")).toBe(true);
  });
});
