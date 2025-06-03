## Summary

This repository, **StreamingAppAzure**, hosts a complete solution for employee monitoring and video recording on Azure, comprised of three main applications—**Admin Dashboard**, **Publisher Electron**, and **TF-API**—plus two shared libraries and full Terraform infrastructure code. The **Admin Dashboard** (React SPA) authenticates admins via Microsoft Entra ID (Azure AD) to view live camera feeds and historical recordings; the **Publisher Electron** app (Windows-only) runs on employee machines, authenticates via Azure AD, and listens for recording commands from a **third-party punch app** through Azure Service Bus sessions; the **TF-API** (containerized) performs TensorFlow video analysis, retrieving models from Key Vault and storing metadata in Cosmos DB. Under the hood, all Azure resources—App Registration with roles/groups, Service Bus namespace/queue, Cosmos DB, Key Vault, ACR, App Service, AKS, Functions, and Storage—are provisioned via Terraform for easy replication. Recording commands originate from the employee’s punch app, not via the admin; when an employee punches in or out, the third-party app enqueues a message in a session-enabled Service Bus queue, which an Azure Function processes to route to the Publisher Electron app. This README explains folder structures, environment setups, and how tokens, messages, and media flow across components.

---

## Table of Contents

1. [Applications and Folder Structures](#applications-and-folder-structures)
   1.1. [Admin Dashboard](#admin-dashboard)
   1.2. [Publisher Electron](#publisher-electron)
   1.3. [TF-API](#tf-api)
2. [Shared Libraries](#shared-libraries)
   2.1. [shared-auth](#shared-auth)
   2.2. [shared-proto](#shared-proto)
3. [End-to-End Flow](#end-to-end-flow)
   3.1. [Authentication via Azure AD](#authentication-via-azure-ad)
   3.2. [Admin Dashboard Runtime Flow](#admin-dashboard-runtime-flow)
   3.3. [Employee Punch App → Service Bus → Publisher Electron Flow](#employee-punch-app--service-bus--publisher-electron-flow)
   3.4. [LiveKit on AKS](#livekit-on-aks)
   3.5. [TF-API TensorFlow Analysis Flow](#tf-api-tensorflow-analysis-flow)
   3.6. [Azure Function & Cosmos DB Interaction](#azure-function--cosmos-db-interaction)
4. [Terraform Infrastructure](#terraform-infrastructure)
   4.1. [Modules and Dependencies](#modules-and-dependencies)
   4.2. [Provisioning Steps](#provisioning-steps)
5. [Local Development & Deployment](#local-development--deployment)
6. [Appendix: Environment Variables](#appendix-environment-variables)

---

## 1. Applications and Folder Structures

### 1.1. Admin Dashboard

**Location**: `apps/admin-dashboard/`

**Purpose**:
The Admin Dashboard is a React single-page application (SPA) used by **Admin** users to:

1. Log in via MSAL.js with Azure AD and obtain an access token containing the “Admin” role. 
2. View live camera feeds of employees in real time by fetching active stream URLs from the backend. 
3. Browse, filter, and play historical recordings stored in Azure Blob Storage via a secure REST API.
4. Send audio commentary to any selected recording by calling the TF-API or Function endpoints.
5. Monitor the recording status of employees (who is currently recording or idle) through a WebSocket connection. 

**Key Technologies**: React (TypeScript), MSAL.js for Azure AD OIDC, Axios for API calls, TailwindCSS for styling, WebSocket for real-time updates. 

**Directory Structure**

```
admin-dashboard/
├── public/
│   ├── favicon.ico
│   ├── index.html
│   └── robots.txt
├── src/
│   ├── components/
│   │   ├── CameraFeed.tsx           # Displays a single HLS/WebRTC stream
│   │   ├── Dashboard.tsx            # Main dashboard view
│   │   ├── FilterBar.tsx            # Date/user filtering UI
│   │   ├── Header.tsx               # Top nav with user info & logout
│   │   ├── Login.tsx                # Triggers MSAL login flow
│   │   ├── RecordingList.tsx        # Lists historical recordings
│   │   ├── Sidebar.tsx              # Navigation: Home, Recordings, Reports
│   │   └── StatusIndicator.tsx      # Shows “Connected”, “Recording”
│   ├── hooks/
│   │   ├── useAuth.ts                # Wraps MSAL.js login, silent token
│   │   ├── useFetch.ts               # Generic fetch wrapper with token
│   │   └── useWebSocket.ts           # Connects to WS, handles reconnection
│   ├── pages/
│   │   ├── HomePage.tsx              # Renders live camera feeds grid
│   │   ├── LoginPage.tsx             # Renders login button if not authenticated
│   │   └── RecordingsPage.tsx        # Renders RecordingList with filters
│   ├── services/
│   │   ├── apiClient.ts              # Axios instance with interceptor for Bearer token
│   │   └── authService.ts            # Wraps MSAL.js for token acquisition/renewal
│   ├── styles/
│   │   ├── App.css                   # Global styles
│   │   └── index.css                 # Tailwind import & custom overrides
│   ├── utils/
│   │   ├── dateUtils.ts              # Parse/format date for filters/reports
│   │   └── formatUtils.ts            # Humanize durations, file sizes
│   ├── App.tsx                       # Main React entry, routes & context providers
│   ├── index.tsx                     # Renders App to DOM
│   ├── react-app-env.d.ts            # TypeScript React definitions
│   └── setupTests.ts                 # Jest setup for testing environment
├── .env                              # REACT_APP_API_URL, REACT_APP_CLIENT_ID, etc.
├── .gitignore
├── package.json
├── README.md                         # (This file)
├── tsconfig.json                     # TypeScript configuration
└── webpack.config.js (or vite.config.ts)
```


---

### 1.2. Publisher Electron

**Location**: `apps/publisher-electron/` 

**Purpose**:
A Windows-only Electron desktop application installed on each employee’s PC whose responsibilities include:

1. **Authentication**: Signs in via MSAL Node (Azure AD) to obtain an access token containing the “Employee” role. 
2. **Auto-Launch & Tray Icon**: Configures itself to start at Windows login, running in the background with a tray icon, preventing non-admins from disabling it. 
3. **Message Listener**: Maintains a persistent connection—either via **WebSocket** or by directly listening on a **Service Bus session-enabled queue**—to receive `RecordingCommand` messages from a **third-party punch app** (when an employee punches in or out).
4. **LiveKit Publishing**: On receiving `RecordingCommand { user: <email>, action: START }`, connects to a LiveKit server (running on AKS) and publishes audio/video tracks; on receiving `STOP`, unpublishes and finalizes uploading to Blob Storage. 
5. **Uploading & Metadata**: After stopping, calls a REST endpoint or Function to upload media to Azure Blob Storage and write metadata to Cosmos DB. 
6. **Logging & Telemetry**: Uses Winston (or similar) for structured logging to disk (rotated daily), capturing errors, token renewals, and recording events.

**Key Technologies**: Electron (TypeScript), MSAL Node (`@azure/msal-node`), Azure Service Bus SDK (`@azure/service-bus`), WebSocket (`ws`), LiveKit JavaScript client, Winston logger.

**Directory Structure**

```
publisher-electron/
├── assets/
│   ├── icon.ico                    # Windows tray icon
│   └── icon.png                    # Fallback PNG icon
├── build/
│   ├── installers/                 # electron-builder output: .exe installer
│   └── resources/
│       ├── splash.png              # Splash image shown during startup
│       └── license.txt             # License for bundling
├── config/
│   ├── msalConfig.ts               # MSAL Node config: clientId, authority, redirectUri
│   ├── appConfig.ts                # SERVICE_BUS_URL, LIVEKIT_WS_URL, API_BASE_URL
│   └── loggerConfig.ts             # Winston: log directory, log level, formats
├── main/
│   ├── main.ts                     # Electron entrypoint: create tray, hidden window, init services
│   ├── autoLaunch.ts               # Register/unregister app for Windows startup via registry
│   ├── windowManager.ts            # Manage hidden BrowserWindow and tray menu
│   ├── ipcHandlers.ts              # IPC between main ↔ renderer (e.g., getStatus)
│   ├── logger.ts                   # Configure and export Winston logger
│   └── README.md                   # Main process architecture notes
├── preload/
│   └── preload.ts                  # Exposes safe APIs (e.g., `window.api.getStatus()`) to renderer
├── renderer/
│   ├── assets/
│   │   ├── logo.svg                # Minimal logo for status window
│   │   └── loading.gif             # Animated loading spinner
│   ├── ui/
│   │   ├── Status.tsx              # Shows current state: “Connecting…”, “Recording”, “Idle”
│   │   └── styles.css              # Styles for the status UI
│   ├── index.html                  # Loads `renderer.js` (bundled)
│   ├── renderer.ts                 # Renderer process: connects to IPC, updates UI
│   ├── renderer.test.ts            # Jest or Playwright tests for renderer logic
│   └── README.md                   # Renderer architecture notes
├── services/
│   ├── auth/
│   │   ├── authService.ts          # MSAL Node: loginRedirect, acquireTokenSilent, logout
│   │   └── authService.test.ts     # Unit tests for token logic
│   ├── websocket/
│   │   ├── websocketService.ts     # Connect, listen for RecordingCommand, handle reconnection
│   │   └── websocketService.test.ts
│   ├── livekit/
│   │   ├── livekitService.ts       # Initialize LiveKit, startPublish(), stopPublish()
│   │   └── livekitService.test.ts
│   ├── recorder/
│   │   ├── recorderService.ts      # On START → livekitService; on STOP → storageService
│   │   └── recorderService.test.ts
│   └── storage/
│       ├── storageService.ts       # Upload to Blob Storage, generate SAS URLs
│       └── storageService.test.ts
├── tests/
│   ├── unit/
│   │   ├── authService.test.ts
│   │   ├── websocketService.test.ts
│   │   └── recorderService.test.ts
│   └── e2e/
│       └── mainWindow.spec.ts      # Spectron test: tray icon, login, simulate START/STOP
├── .env                            # MSAL_CLIENT_ID, MSAL_TENANT_ID, SERVICE_BUS_URL, LIVEKIT_WS_URL, etc.
├── .gitignore
├── electron-builder.json           # NSIS installer config: appId, icons, one-click install, shortcuts
├── package.json                    # Scripts: “start”, “build”, “package”; dependencies
├── tsconfig.json                   # TS config, path aliases (@main, @services)
├── webpack.main.config.js          # Bundle `main.ts` → `dist/main.js`
├── webpack.renderer.config.js      # Bundle `renderer.ts` → `dist/renderer.js`
└── README.md                       # Overview, build & packaging instructions (you’re reading it now)
```



---

### 1.3. TF-API

**Location**: `apps/tf-api/` 

**Purpose**:
A containerized service (Node.js + Express or Python + FastAPI) that:

1. **Inference Endpoint**: Exposes `POST /api/analyze-frame`, accepts a frame reference or blob URL, runs a TensorFlow model, and returns `AnalysisResult { user, label, confidence, timestamp }`. 
2. **Model Management**: On startup, fetches model URIs from Key Vault via `keyVaultService.ts`, then downloads model files from Blob Storage to local disk for inference. 
3. **Cosmos DB Writes**: After inference, writes to Cosmos DB container `analysisResults` with partition key `/user`.
4. **Health Check**: `GET /api/health` returns status, verifying token validation and model load—used for Kubernetes liveness/readiness probes.
5. **Secured by JWT**: Applies `authenticateTokenMiddleware` from `shared-auth` to all routes (except `/api/health`) to verify Azure AD tokens. 

**Key Technologies**: Node.js + Express (or Python + FastAPI), TensorFlow\.js (Node) or TensorFlow Python, Azure Key Vault SDK, Azure Cosmos DB SDK, shared-auth middleware.

**Directory Structure**

```
tf-api/
├── Dockerfile                        # Base image: node:18-slim, installs dependencies, copies build
├── package.json (or requirements.txt) # Dependencies: express, @azure/cosmos, @tensorflow/tfjs-node, @azure/keyvault-secrets
├── src/
│   ├── controllers/
│   │   ├── analyzeController.ts       # Handles /api/analyze-frame
│   │   ├── modelsController.ts        # Handles /api/models (list available model URIs)
│   │   └── healthController.ts        # Handles /api/health
│   ├── middleware/
│   │   ├── authMiddleware.ts          # Verifies JWT with shared-auth decode & validation
│   │   └── errorHandler.ts            # Catches errors and returns standardized JSON
│   ├── services/
│   │   ├── tfService.ts               # Loads TensorFlow model, runs inference on frames
│   │   ├── keyVaultService.ts         # Uses Managed Identity to fetch secrets from Key Vault
│   │   └── cosmosService.ts           # Initializes Cosmos DB client, writes analysis results
│   ├── utils/
│   │   ├── azureConfig.ts             # Reads AZURE_* env vars, constructs config objects
│   │   └── logging.ts                 # Sets up Winston for server logs
│   ├── index.ts                       # Binds controllers, middleware, starts Express server
│   └── README.md                      # API documentation, example requests, environment setup
├── test/
│   ├── analyzeController.test.ts      # Mocks tfService and verifies correct response shape
│   ├── tfService.test.ts              # Loads a small dummy model and verifies inference output
│   └── middleware.test.ts             # Simulates requests with valid/invalid JWTs and checks status codes
├── tsconfig.json (or pyproject.toml)  # TypeScript (or Python) config
└── README.md                          # Overview, local run & Docker build instructions
```


---

## 2. Shared Libraries

### 2.1. shared-auth

**Location**: `libs/shared-auth/` 

**Purpose**:
A reusable TypeScript library that centralizes authentication logic across **admin-dashboard**, **publisher-electron**, and **tf-api**:

1. **MSAL Configuration**: Contains a single source of truth (`msalConfig.ts`) for `clientId`, `tenantId`, `authority`, `redirectUri`, and scopes for both browser (MSAL React) and Node (MSAL Node) flows.
2. **JWT Utilities**: Exposes `decodeToken(token)`, `isTokenExpired(token)`, and `renewToken(account, scopes)` that wrap MSAL’s silent token acquisition.
3. **Express Middleware**: `authenticateTokenMiddleware(req, res, next)` verifies incoming JWT (signature, issuer, audience, roles) and either attaches user claims to `req` or returns 401/403.
4. **Shared Types**: Defines TypeScript interfaces: `AuthConfig`, `TokenClaims` (with `roles`, `preferred_username`, `oid`), and `UserProfile`. 

**Directory Structure**

```
shared-auth/
├── src/
│   ├── index.ts              # Exports MSAL functions, middleware, types
│   ├── msalConfig.ts         # MSAL Browser & Node configuration (PublicClientApplication)
│   ├── authHelpers.ts        # decodeToken, isTokenExpired, renewToken
│   ├── types.ts              # AuthConfig, TokenClaims, UserProfile
│   └── middleware.ts         # Express middleware: validate Bearer JWT
├── test/
│   ├── authHelpers.test.ts   # Unit tests for decodeToken & isTokenExpired
│   └── middleware.test.ts    # Unit tests for middleware with valid vs invalid tokens
├── package.json
├── tsconfig.json
└── README.md                 # Usage examples for frontend, Electron, server
```


---

### 2.2. shared-proto

**Location**: `libs/shared-proto/` 
**Purpose**:
Defines Protobuf schemas and generates language-specific stubs so that **publisher-electron**, **admin-dashboard**, and **tf-api** share a common message format:

1. **`proto/recording.proto`**:

   ```proto
   syntax = "proto3";
   package shared;

   message RecordingCommand {
     string user = 1;
     enum Action { START = 0; STOP = 1; }
     Action action = 2;
   }
   ```

   (Used by third-party punch app → Service Bus → Azure Function → Publisher Electron) 

2. **`proto/analysis.proto`**:

   ```proto
   syntax = "proto3";
   package shared;

   message AnalysisResult {
     string user = 1;
     float  confidence = 2;
     string label = 3;
     int64 timestamp = 4;
   }
   ```

   (Returned by TF-API after model inference) 

3. **`proto/common.proto`**:

   ```proto
   syntax = "proto3";
   package shared;

   import "google/protobuf/timestamp.proto";

   message Empty {}

   message Timestamp {
     google.protobuf.Timestamp ts = 1;
   }
   ```

4. **Generated Stubs**:

   * `gen/js/`: CommonJS stubs for Node.js (used by **tf-api**) 
   * `gen/ts/`: TypeScript ES module stubs (used by **admin-dashboard** & **publisher-electron**)

5. **Script**:

   * `scripts/gen-proto.ps1`: PowerShell to run `protoc` with `--js_out` and `--ts_out` to populate `gen/js` and `gen/ts`. 

**Directory Structure**

```
shared-proto/
├── proto/
│   ├── recording.proto
│   ├── analysis.proto
│   └── common.proto
├── gen/
│   ├── js/       # Node.js stubs generated by protoc
│   └── ts/       # TypeScript stubs generated by ts-protoc-gen
├── scripts/
│   └── gen-proto.ps1  # PowerShell script to regenerate stubs
├── package.json
├── tsconfig.json
└── README.md            # Explains how to run `npm run gen:proto`
```


---

## 3. End-to-End Flow

### 3.1. Authentication via Azure AD

1. **Admin Dashboard**:

   * On initial load, `authService.loginRedirect()` uses MSAL.js to redirect the user to `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize?client_id=<clientId>&redirect_uri=https://admin.collettehealth.com&response_type=code&scope=openid profile user_impersonation` for interactive login. 
   * After successful sign-in, Azure AD returns an ID token (to display user info) and an access token (with `roles` claim containing `["Admin"]`). 
   * MSAL caches tokens in browser storage; subsequent silent renewals use `acquireTokenSilent()`.

2. **Publisher Electron**:

   * On first run, `authService.loginRedirect()` (MSAL Node) launches a hidden Electron window to `msal://<clientId>/auth`. 
   * Electron intercepts `msal://` callback, extracts the authorization code, exchanges it for tokens (ID & access), and caches them to disk.
   * On subsequent launches, `acquireTokenSilent()` renews tokens; if renewal fails, fallback to interactive login. 

3. **TF-API**:

   * When Admin Dashboard or Publisher Electron calls `/api/analyze-frame`, they include `Authorization: Bearer <access_token>`. 
   * `authenticateTokenMiddleware` decodes and verifies the JWT (signature, issuer, audience, roles). If valid, `req.user` is populated with claims and the request proceeds; otherwise, 401/403.

---

### 3.2. Admin Dashboard Runtime Flow

1. **Initial Load**:

   * User navigates to `https://admin.collettehealth.com`; if no valid token, invoked `loginRedirect()`, which redirects to Azure AD sign-in page.
   * Upon successful login, React App renders `HomePage.tsx`, which calls `apiClient.get("/api/activeStreams")` to fetch live camera feed URLs. 

2. **Fetch Live Camera Links**:

   * The HTTP call goes to an Azure Function (HTTP-trigger) `getActiveStreams`, which queries Cosmos DB or Service Bus to determine which employees are currently recording.
   * The Function returns a JSON array of `{ user, streamUrl }` where each `streamUrl` points to LiveKit’s HLS or WebRTC endpoint. 
   * React’s `CameraFeed` components subscribe to these URLs via `<video src={streamUrl} />`.

3. **Real-Time Notifications**:

   * Separately, the Dashboard’s `useWebSocket` hook connects to a WebSocket (or SignalR) endpoint `wss://<signalr-endpoint>`. 
   * When an Azure Function finalizes a recording (after the employee’s punch app sent STOP), the Function broadcasts `NEW_RECORDING` event:

     ```json
     {
       "type": "NEW_RECORDING",
       "payload": {
         "user": "bob@company.com",
         "recordingUrl": "https://colletteprodstorage.blob.core.windows.net/recordings/bob-20250603.mp4",
         "timestamp": 1685793600
       }
     }
     ```
   * `useWebSocket` receives this and updates `RecordingList`, adding the new entry.

---

### 3.3. Employee Punch App → Service Bus → Publisher Electron Flow

1. **Third-Party Punch App (Employee’s Clock-In/Clock-Out)**:

   * Installed on employee machines or mobile devices, this app collects employee login/logout events (“punch in“ / “punch out“). 
   * On “punch in”, it calls an Azure Function endpoint `enqueueRecordingCommand` (HTTP-trigger) to send `{ user: "bob@company.com", action: "START" }`. 
   * On “punch out”, it calls the same Function with `action: "STOP"`. 

2. **Azure Function: enqueueRecordingCommand**:

   * Triggered by HTTP POST from Punch App; the Function runs `authenticateTokenMiddleware` to verify the user has a valid token (though Punch App might use client credentials or a service principal to authenticate). 
   * Creates a `ServiceBusMessage` with `body = { user, action }` and `sessionId = user` and sends it to the Service Bus `EmployeeCommandQueue` (`requiresSession = true`).
   * Responds 200 OK. 

3. **Azure Function: processRecordingCommand**:

   * Trigger: **Service Bus Queue-trigger** on `EmployeeCommandQueue` with `isSessionsEnabled = true`.
   * Receives the message with `SessionId = bob@company.com` and `body = { user: "bob@company.com", action: "START" }` or `{ action: "STOP" }`.
   * Locates the Publisher Electron instance associated with `user`:

     * If `action === "START"`:

       * Invokes a broadcast (via Service Bus or SignalR) to notify that Publisher Electron should start recording; for example, Service Bus could route a second message or an RPC to the Electron app’s WebSocket endpoint. 
     * If `action === "STOP"`:

       * Instructs Publisher Electron to stop recording; once Publisher Electron finishes uploading media, the Function retrieves the SAS URL and writes to Cosmos DB (recording metadata).
       * Optionally, triggers the WebSocket event `NEW_RECORDING` so Admin Dashboards can update.
   * Completes the message to remove it from the queue.

4. **Publisher Electron (Employee App)**:

   * `websocketService` is connected to the Function’s WebSocket or SignalR hub on startup.

   * Alternatively, a `ServiceBusReceiver` (session client) is created with `sessionId = bob@company.com`. 

   * On `RecordingCommand { action: START }`:

     * Calls `recorderService.startRecording()`:

       1. Calls a **LiveKit Function** to generate a short-lived LiveKit access token (via `livekitService.getToken()`).
       2. Uses LiveKit SDK to `connect(url, token)` to join a room. 
       3. `livekitService.startPublish(localVideoTrack, localAudioTrack)`. 

   * While LiveKit is publishing, Electron logs events (e.g., “Connected to room X”, “Started publishing”).

   * On `RecordingCommand { action: STOP }`:

     * Calls `livekitService.stopPublish()`, gracefully unpublishing tracks. 
     * If any local media files (e.g., short MP4 or HLS segments) exist, calls `storageService.uploadRecording(localFilePath)`:

       * Uploads to `recordings` container in Blob Storage: `bob-20250603-0930.mp4`. 
       * Sets metadata such as contentType, tier=Hot. 
       * Generates a **SAS URL** valid for 30 days.
     * Calls a Function REST endpoint `postRecordingMetadata` with `{ user, recordingUrl, durationSec, timestampStart }`.
     * Receives 200 OK and updates tray UI to “Idle”. 

5. **Error Handling & Reconnection**:

   * If WebSocket / Service Bus connection drops, `websocketService` retries with exponential backoff.
   * If LiveKit token expires mid-session, `livekitService` requests a new token from the Function and re-joins the room seamlessly.

---

### 3.4. LiveKit on AKS

1. **AKS Cluster** (`ColletteHealthProdAKS`):

   * Provisioned with **Azure CNI** and **Standard Load Balancer** for stable egress IPs and efficient network routing. 

   * Contains two node pools:

     * **system node pool** (Standard\_B2s, 1 node) for control-plane add-ons (CoreDNS, metrics-server, etc.)
     * **spot node pool** (Standard\_D4as\_v5, 0–2 nodes, `priority = Spot`, autoscale) for LiveKit server pods. 

2. **Deploying LiveKit**:

   * Use the official LiveKit **Helm chart** or custom Kubernetes manifests to deploy LiveKit server pods.
   * Configure a **Service** of type `LoadBalancer` exposing ports for WebSocket signaling (TCP 7880) and RTP/RTCP (UDP 10000–20000).
   * Enable **Horizontal Pod Autoscaler** for the spot pool: scale from 0 to 2 pods based on CPU/memory or custom metrics (e.g., active connections). 
   * Optionally enable LiveKit’s recording service to write directly to Blob Storage or generate HLS streams. 

3. **Publisher Electron → LiveKit**:

   * The Publisher Electron app’s `livekitService.connect()` uses the `LIVEKIT_WS_URL = wss://livekit.<aks-domain>.azurecr.io`. 
   * The Function `getLiveKitToken` uses LiveKit’s REST API Key/Secret (stored in Key Vault) to generate a time-bounded token embedding `room` and `identity = <user>`. 
   * LiveKit verifies the token, joins the client to the room, and starts forwarding media to other subscribers (Admin Dashboard or internal recording service). 

---

### 3.5. TF-API TensorFlow Analysis Flow

1. **Model Loading**:

   * `tfService.loadModel()` calls `keyVaultService.getSecret("model-v1-path")` to retrieve the Blob Storage URI (e.g., `https://<blob>.blob.core.windows.net/models/model-v1.pb`). 
   * Downloads the model locally (if not already in cache) and loads it into TensorFlow runtime (`tf.loadGraphModel(path)`).

2. **Analysis Request**:

   * Client sends:

     ```http
     POST /api/analyze-frame
     Authorization: Bearer <access_token>
     Content-Type: application/json

     {
       "blobUrl": "https://colletteprodstorage.blob.core.windows.net/recordings/bob-20250603.mp4",
       "frameTimestamp": 1685787000
     }
     ```
   * `authMiddleware` validates the JWT (same as Admin Dashboard).
   * `analyzeController` uses `tfService.extractFrame(blobUrl, timestamp)` to fetch the specified frame, runs `tfService.runInference(frameTensor)`, producing `label` and `confidence`. 
   * Returns:

     ```json
     {
       "user": "bob@company.com",
       "label": "HelmetDetected",
       "confidence": 0.87,
       "timestamp": 1685787000
     }
     ```

3. **Cosmos DB Write**:

   * `cosmosService.saveAnalysisResult({ user, label, confidence, timestamp })` writes to Cosmos DB container `analysisResults` (partition key `/user`). 
   * Ensures that analysis metadata is available for Admin Dashboard to query for reports. 

4. **Health Check & Metrics**:

   * `GET /api/health` returns `{ status: "OK" }` if the server can decode tokens, connect to Key Vault, and load the model.
   * Kubernetes liveness/readiness probes ping this endpoint every 30 seconds; failure triggers pod restart. 

---

### 3.6. Azure Function & Cosmos DB Interaction

1. **Function: postRecordingMetadata**:

   * Trigger: **HTTP** POST from Publisher Electron after uploading the final media. 
   * Validates JWT (must have “Employee” or “Admin” role). 
   * Inserts a document into Cosmos DB `recordings` container:

     ```json
     {
       "id": "<guid>",
       "user": "bob@company.com",
       "recordingUrl": "https://colletteprodstorage.blob.core.windows.net/recordings/bob-20250603-0930.mp4?sv=...",
       "timestamp": 1685786400,
       "durationSec": 360
     }
     ```
   * Responds 200 OK.

2. **Function: getVideoUrls**:

   * Trigger: **HTTP** GET from Admin Dashboard to list recordings.
   * Queries Cosmos DB `recordings` container for documents by `/user` or by date range using SQL API:

     ```sql
     SELECT * FROM recordings r WHERE r.user = @user AND r.timestamp BETWEEN @start AND @end
     ```
   * Returns array of `{ recordingUrl, timestamp, durationSec }`. 

3. **WebSocket Broadcast (SignalR)**:

   * After inserting metadata (in `processRecordingCommand` or `postRecordingMetadata`), calls a **SignalR Service** to broadcast `NEW_RECORDING` to all connected Admin Dashboard clients.
   * SignalR ensures low-latency updates for UIs.

---

## 4. Terraform Infrastructure

### 4.1. Modules and Dependencies

All Terraform code resides under `terraform/`, broken into modules that encapsulate each Azure service. The **root module** (`terraform/main.tf`) invokes submodules in dependency order:

1. **`modules/aad/`**:

   * Creates a unified **Azure AD App Registration** (`ColletteHealthProdUnifiedApp`) with two **App Roles** (“Admin” & “Employee”).
   * Defines **Redirect URIs**: `https://admin.collettehealth.com` (Admin Dashboard) and `msal://<appId>/auth` (Electron). 
   * Creates two **Security Groups**: `ColletteHealth-Admins` and `ColletteHealth-Employees`, and assigns App Roles accordingly.

2. **`modules/servicebus/`**:

   * Creates a **Service Bus namespace** (`ColletteHealthProdSB`, Standard SKU). 
   * Creates a **queue** (`EmployeeCommandQueue`) with `requiresSession = true` to guarantee FIFO per user session. 

3. **`modules/cosmosdb/`**:

   * Deploys an **Azure Cosmos DB account** (`ColletteHealthProdCosmos`) in Serverless mode (Core SQL API).
   * Creates a **database** (`colletteDatabase`) and two **containers**:

     * `recordings` (partition key `/user`)
     * `analysisResults` (partition key `/user`) 

4. **`modules/keyvault/`**:

   * Creates **Azure Key Vault** (`ColletteHealthProdKV`) with `soft_delete_enabled = true`, `purge_protection = true`.
   * Grants the **Function App’s system-assigned identity** access policies for “get” and “list” secrets.

5. **`modules/acr/`**:

   * Creates **Azure Container Registry** (`ColletteHealthProdACR`) in Basic SKU with admin user disabled. 
   * Enables Geo-replication (Premium SKU) if multi-region deployment required. 

6. **`modules/appservice/`**:

   * Creates an **App Service Plan** (`ColletteHealthProdASP`, Linux, Basic\_B1, capacity = 1, autoscale 1→3). 
   * Deploys **Admin Dashboard** as `azurerm_linux_web_app` (`NODE|20-lts`, `WEBSITE_RUN_FROM_PACKAGE = 1`, TLS 1.2 enforced). 
   * Deploys **TF-API** as `azurerm_linux_web_app` from ACR image (`DOCKER|<acr>/tf-api:latest`), with FTPS disabled, TLS 1.2, Managed Identity for ACR pull & Key Vault. 
   * Optionally a **staging slot** (“staging”) for Admin Web App if `enable_slot = true`. 

7. **`modules/aks/`**:

   * Creates an **AKS cluster** (`ColletteHealthProdAKS`) with:

     * **network\_plugin = "azure"**, **outbound\_type = "loadBalancer"** for dedicated egress. 
     * **system node pool** (Standard\_B2s, 1 node) for CoreDNS, metrics-server.
     * **spot node pool** (Standard\_D4as\_v5, 0–2 nodes, `priority = Spot`, autoscale 0→2).
   * Assigns **AcrPull** role to AKS managed identity so pods can pull from ACR. 

8. **`modules/functions/`**:

   * Creates a **Storage Account** (`ColletteHealthProdFuncSA`, Standard\_LRS) for Function code. 
   * Creates a **Consumption Plan Function App** (`ColletteHealthProdFunctionApp`, Node runtime) with system-assigned identity.
   * Grants **Service Bus Data Sender** role on Service Bus namespace and **Cosmos DB Built-in Data Contributor** on Cosmos DB account to the Function identity. 

9. **`modules/storage/`**:

   * Creates **Storage Account** (`collettehealthprodstorage`, StorageV2, HTTPS only) with static website enabled.
   * Creates **private container** (`installers`) for Electron installers and **container** (`recordings`) for final media.

---

### 4.2. Provisioning Steps

1. **Login & Select Subscription**

   ```bash
   az login
   az account set --subscription "Microsoft Azure Sponsorship"
   ```


2. **Initialize Terraform**

   ```bash
   cd terraform
   terraform init \
     -backend-config="resource_group_name=RG-TerraformState" \
     -backend-config="storage_account_name=tfstatestorage" \
     -backend-config="container_name=terraform-state" \
     -backend-config="key=collettehealth.tfstate"
   ```

  

3. **Validate Configuration**

   ```bash
   terraform validate
   ```

   Ensures syntax and resource definitions are correct. 

4. **Plan Deployment**

   ```bash
   terraform plan -var-file="environments/prod.tfvars"
   ```

   Shows a preview of resources to be created/updated. 

5. **Apply Deployment**

   ```bash
   terraform apply -var-file="environments/prod.tfvars"
   ```

   Creates all Azure resources in dependency order. Outputs include:

   * `adminDashboardURL`, `tfApiURL`, `acrLoginServer`, `aksClusterName`, `functionAppURL`, `storageAccountName`.
  

6. **Post-Provisioning**

   * **Build & Push TF-API**:

     ```bash
     az acr build --registry collettehealthprodacr --image tf-api:latest --file apps/tf-api/Dockerfile apps/tf-api
     ```

   * **Deploy Electron Installer**:

     ```bash
     az storage blob upload \
       --account-name collettehealthprodstorage \
       --container-name installers \
       --name publisher-installer.exe \
       --file path\to\publisher-installer.exe \
       --auth-mode login
     ```

 
   * **Deploy LiveKit to AKS**:

     ```bash
     helm repo add livekit https://charts.livekit.io
     helm install livekit-server livekit/livekit-server \
       --set config.key=<LiveKitKey>,config.secret=<LiveKitSecret>
     ```



---

## 5. Local Development & Deployment

### 5.1. Admin Dashboard

1. **Environment Variables** (`apps/admin-dashboard/.env`):

   ```
   REACT_APP_API_URL=https://collettehealthprodtfapiwebapp.azurewebsites.net
   REACT_APP_CLIENT_ID=<AzureAD_AppID>
   REACT_APP_TENANT_ID=<AzureAD_TenantID>
   REACT_APP_REDIRECT_URI=http://localhost:3000
   ```


2. **Install & Start**:

   ```bash
   cd apps/admin-dashboard
   npm install
   npm run start
   ```

   * Runs on `http://localhost:3000`; triggers MSAL login via `http://localhost:3000`.

3. **Build for Production**:

   ```bash
   npm run build
   ```

   * Outputs to `build/`; used by Terraform to deploy via `WEBSITE_RUN_FROM_PACKAGE`. 

---

### 5.2. Publisher Electron

1. **Environment Variables** (`apps/publisher-electron/.env`):

   ```
   MSAL_CLIENT_ID=<AzureAD_AppID>
   MSAL_TENANT_ID=<AzureAD_TenantID>
   MSAL_REDIRECT_URI=msal://<AzureAD_AppID>/auth
   SERVICE_BUS_URL=Endpoint=sb://collettehealthprodsb.servicebus.windows.net/;SharedAccessKeyName=<KeyName>;SharedAccessKey=<KeyValue>
   LIVEKIT_WS_URL=wss://livekit-server.<aks-domain>.azurecr.io
   LIVEKIT_API_KEY=<LiveKitKey>
   LIVEKIT_API_SECRET=<LiveKitSecret>
   API_BASE_URL=https://collettehealthprodtfapiwebapp.azurewebsites.net
   ```



2. **Install & Run (Dev)**:

   ```bash
   cd apps/publisher-electron
   npm install
   npm run start
   ```

   * Opens a tray icon; attempts silent token acquisition.

3. **Build & Package**:

   ```bash
   npm run build
   npm run package
   ```

   * Produces `publisher-installer.exe` in `build/installers/`.
   * Upload to Storage as shown above. 

---

### 5.3. TF-API

1. **Environment Variables** (`apps/tf-api/.env`):

   ```
   AZURE_TENANT_ID=<AzureAD_TenantID>
   AZURE_CLIENT_ID=<FunctionApp_SP_ClientID>
   AZURE_CLIENT_SECRET=<FunctionApp_SP_Secret>
   AZURE_COSMOS_ENDPOINT=https://<cosmos-account>.documents.azure.com:443/
   AZURE_COSMOS_KEY=<cosmos-key>
   AZURE_COSMOS_DATABASE=colletteDatabase
   KEY_VAULT_URL=https://<vault-name>.vault.azure.net/
   MODEL_BLOB_CONTAINER=models
   API_PORT=3000
   ```



2. **Install & Run Locally**:

   ```bash
   cd apps/tf-api
   npm install
   npm run build
   npm run start
   ```

   * Serves on `http://localhost:3000`; test with `curl http://localhost:3000/api/health`.
   * Test inference:

     ```bash
     curl -X POST http://localhost:3000/api/analyze-frame \
       -H "Authorization: Bearer <validToken>" \
       -H "Content-Type: application/json" \
       -d '{"blobUrl":"https://.../sample-frame.jpg","frameTimestamp":1685787000}'
     ```



3. **Containerize & Push**:

   ```bash
   cd apps/tf-api
   docker build -t collettehealthprodacr.azurecr.io/tf-api:latest .
   docker push collettehealthprodacr.azurecr.io/tf-api:latest
   ```

   * AKS or App Service pulls this image as part of deployment. 

---

## 6. Appendix: Environment Variables

Below is a consolidated list of `.env` variables across all apps. For production, use secure Azure Key Vault references or Azure App Settings.

### Admin Dashboard (`apps/admin-dashboard/.env`)

```
REACT_APP_API_URL=https://collettehealthprodtfapiwebapp.azurewebsites.net
REACT_APP_CLIENT_ID=<AzureAD_AppID>
REACT_APP_TENANT_ID=<AzureAD_TenantID>
REACT_APP_REDIRECT_URI=http://localhost:3000
```

^([learn.microsoft.com][2], [learn.microsoft.com][3])

### Publisher Electron (`apps/publisher-electron/.env`)

```
MSAL_CLIENT_ID=<AzureAD_AppID>
MSAL_TENANT_ID=<AzureAD_TenantID>
MSAL_REDIRECT_URI=msal://<AzureAD_AppID>/auth
SERVICE_BUS_URL=Endpoint=sb://collettehealthprodsb.servicebus.windows.net/;SharedAccessKeyName=<KeyName>;SharedAccessKey=<KeyValue>
LIVEKIT_WS_URL=wss://livekit-server.<aks-domain>.azurecr.io
LIVEKIT_API_KEY=<LiveKitKey>
LIVEKIT_API_SECRET=<LiveKitSecret>
API_BASE_URL=https://collettehealthprodtfapiwebapp.azurewebsites.net
```

^([github.com][10], [learn.microsoft.com][8])

### TF-API (`apps/tf-api/.env`)

```
AZURE_TENANT_ID=<AzureAD_TenantID>
AZURE_CLIENT_ID=<FunctionApp_SP_ClientID>
AZURE_CLIENT_SECRET=<FunctionApp_SP_Secret>
AZURE_COSMOS_ENDPOINT=https://<cosmos-account>.documents.azure.com:443/
AZURE_COSMOS_KEY=<cosmos-key>
AZURE_COSMOS_DATABASE=colletteDatabase
KEY_VAULT_URL=https://<vault-name>.vault.azure.net/
MODEL_BLOB_CONTAINER=models
API_PORT=3000
```

^([sqlshack.com][15], [learn.microsoft.com][24])

---

