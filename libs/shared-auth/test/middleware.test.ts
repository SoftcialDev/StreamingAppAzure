// test/middleware.test.ts

import express from "express";
import { Request, Response } from "express";
import request from "supertest";
import * as jwt from "jsonwebtoken";
import { authenticateTokenMiddleware, UserRequest } from "../src/middleware";

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

function createTestApp(roles: string[] = ["Admin"]) {
  const app = express();
  app.get(
    "/protected",
    authenticateTokenMiddleware(roles),
    (req: Request, res: Response) => {
      res.status(200).json({
        message: "Access granted",
        user: (req as UserRequest).user,
      });
    }
  );
  return app;
}

describe("Auth Middleware", () => {
  test("allows access with valid token and role", async () => {
    const app = createTestApp(["Admin"]);
    const response = await request(app)
      .get("/protected")
      .set("Authorization", `Bearer ${token}`);
    expect(response.status).toBe(200);
    expect(response.body.message).toBe("Access granted");
    expect(response.body.user.name).toBe("Test User");
  });

  test("denies access with missing token", async () => {
    const app = createTestApp();
    const response = await request(app).get("/protected");
    expect(response.status).toBe(401);
    expect(response.body.message).toMatch(/access token is missing/i);
  });

  test("denies access with invalid role", async () => {
    const invalidPayload = { ...payload, roles: ["User"] };
    const invalidToken = jwt.sign(invalidPayload, "test-secret");
    const app = createTestApp(["Admin"]);
    const response = await request(app)
      .get("/protected")
      .set("Authorization", `Bearer ${invalidToken}`);
    expect(response.status).toBe(403);
    expect(response.body.message).toMatch(/insufficient role/i);
  });

  test("denies access if claims are missing", async () => {
    const badPayload = {
      aud: "x",
      iss: "y",
      exp: Math.floor(Date.now() / 1000) + 60,
    };
    const badToken = jwt.sign(badPayload, "test-secret");
    const app = createTestApp(["Admin"]);
    const response = await request(app)
      .get("/protected")
      .set("Authorization", `Bearer ${badToken}`);
    expect(response.status).toBe(403);
    expect(response.body.message).toMatch(/claims missing/i);
  });

 test("denies access with malformed token", async () => {
  const app = createTestApp();
  const response = await request(app)
    .get("/protected")
    .set("Authorization", "Bearer not.a.jwt");
  expect(response.status).toBe(403);
  expect(response.body.message).toMatch(/required claims missing in token/i);
});
});
