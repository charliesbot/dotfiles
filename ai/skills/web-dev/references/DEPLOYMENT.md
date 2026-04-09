# Deployment & Infrastructure Guide

## Table of Contents

- [Firebase App Hosting](#firebase-app-hosting)
- [apphosting.yaml](#apphostingyaml)
- [Backend Logic](#backend-logic)
- [Cloud DNS Setup](#cloud-dns-setup)
- [Free Tier Reference](#free-tier-reference)
- [Cloud Run (Escape Hatch)](#cloud-run-escape-hatch)

## Firebase App Hosting

All projects use **Firebase App Hosting** — SPA and SSR alike. Git-push deploys with zero infra config.

### Setup

1. Create the App Hosting backend:

   ```bash
   firebase apphosting:backends:create --project <project-id> --backend <backend-name> --primary-region us-central1
   ```

   **⚠️ This opens your browser** to connect the GitHub repo via Developer Connect (one-time step per repo). Always warn the user before running this command so they're prepared for the browser prompt. Select the repo and branch to deploy from.

2. App Hosting auto-detects Angular and builds accordingly (SSR is enabled by default).

3. To trigger a manual rollout (e.g., after connecting):
   ```bash
   firebase apphosting:rollouts:create <backend-name> --git-branch main
   ```

### Deploy

Push to the connected branch. App Hosting builds and deploys automatically. Each push creates a rollout — use rollout URLs for previewing before promoting.

## apphosting.yaml

Use `apphosting.yaml` in the root directory to manage runtime settings and environment variables.

### Example configuration

```yaml
runConfig:
  cpu: 1
  memoryMiB: 1024
  minInstances: 0 # Scale to zero when inactive (free tier friendly)
  maxInstances: 10 # Limit scaling to control costs
  concurrency: 100 # Handle up to 100 requests per instance

env:
  # Static environment variables
  - variable: STORAGE_BUCKET
    value: my-app.appspot.com
    availability: [RUNTIME]

  # Secrets from Cloud Secret Manager
  # Set via: firebase apphosting:secrets:set API_KEY
  - variable: API_KEY
    secret: API_KEY
    availability: [BUILD, RUNTIME]
```

### Custom domain

1. Add `projectname.charlies.bot` in Firebase console → App Hosting → Custom domains
2. Use `run_gcloud_command` to add the DNS records in Cloud DNS (see DNS section below)
3. SSL is auto-provisioned — no manual cert setup

### MCP tools

- `firebase_list_apps` — list all Firebase apps in the project.
- `firebase_get_environment` — view current Firebase project and user context.

## Backend Logic

**Angular server routes** are the default for API endpoints — they run on the same App Hosting Node.js server, deploy with the app, and need zero extra infrastructure.

**Cloud Functions** are for logic that must run independently: Firestore triggers, auth triggers, scheduled tasks, or reusable services shared across multiple apps. Use Cloud Functions v2 (`firebase-functions/v2`). Import from `firebase-functions/v2/https`, `firebase-functions/v2/firestore`, `firebase-functions/v2/identity`, or `firebase-functions/v2/scheduler` as needed.

```bash
firebase deploy --only functions        # Deploy all functions
firebase deploy --only functions:api    # Deploy specific function
firebase emulators:start --only functions,firestore,auth  # Local dev
```

Debug with `mcp__plugin_firebase_firebase__functions_get_logs`.

## Cloud DNS Setup

Every project gets `projectname.charlies.bot`. DNS is managed in Cloud DNS via gcloud MCP.

### Add a subdomain record

Use `run_gcloud_command` with:

```bash
gcloud dns record-sets create projectname.charlies.bot. \
  --zone=charlies-bot \
  --type=A \
  --ttl=300 \
  --rrdatas=<firebase-hosting-ip>
```

For App Hosting, you may also need a TXT record for domain verification. Firebase console shows the exact values.

### CNAME alternative (Firebase App Hosting)

Use `run_gcloud_command` with:

```bash
gcloud dns record-sets create projectname.charlies.bot. \
  --zone=charlies-bot \
  --type=CNAME \
  --ttl=300 \
  --rrdatas=<app-hosting-domain>.
```

## Free Tier Reference

| Service         | Free tier limit                                               |
| --------------- | ------------------------------------------------------------- |
| App Hosting     | Git-push deploys, auto-scaling, included in Firebase plan     |
| Firestore       | 1 GiB storage, 50K reads/day, 20K writes/day, 20K deletes/day |
| Firebase Auth   | 50K MAU (email/password, Google)                              |
| Cloud Functions | 2M invocations/month, 400K GB-seconds, 200K GHz-seconds       |
| Cloud Storage   | 5 GB storage, 1 GB/day download                               |

Design for these limits. If a side project exceeds free tier, it's probably successful enough to pay for.

## Cloud Run (Escape Hatch)

Use Cloud Run only when Cloud Functions genuinely can't handle it — e.g., long-running processes, WebSocket servers, or custom container requirements.

Deploy via gcloud MCP:

```bash
gcloud run deploy <service-name> \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

Map to subdomain via Cloud DNS (same process as above). This should be rare — Angular server routes and Cloud Functions cover the vast majority of backend needs.
