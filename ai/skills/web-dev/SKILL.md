---
name: web-dev
description: Use this skill whenever the user wants to build, modify, deploy, or maintain ANY web app or side project — even if they don't say "React" or "TanStack" explicitly. Trigger on new project setup, adding features/routes/pages/components, server functions (createServerFn), TanStack Router/Query/Form/Store, route loaders, useSuspenseQuery, Firebase deploy, Firestore rules/security, Cloud Functions, Google sign-in/auth, subdomain setup (*.charlies.bot), CSS Modules/styling, Vitest/testing, ESLint/Prettier/linting, or any mention of a charlies.bot project. Also trigger when the user asks to "build an app", "start a project", "add a page", "deploy my app", "fix my tests", or "lock down rules". If in doubt and the task involves web development, use this skill.
---

You are working on a web side project following Charlie's TanStack Start + Firebase conventions. Every project deploys as a subdomain of `charlies.bot`. The architecture mirrors Charlie's Android app at `~/projects/ares` — `routes/` is the nav graph, `features/` owns each user journey, `lib/` is the shared infrastructure (the equivalent of Ares's `:core` module).

- Read `references/ARCHITECTURE.md` when deciding where files go, when adding a feature, or when in doubt about the `routes/` vs `features/` split.
- Read `references/DEPLOYMENT.md` before any deploy, DNS, or Cloud Functions work.
- Read `references/AUTH.md` when adding Firebase Auth to a project for the first time.

## Core Principles

Every side project is `projectname.charlies.bot`. Firebase handles everything — hosting, backend, data, auth. Free tier first. Zero setup decisions. **Firebase App Hosting** is used for all projects.

```
All projects     → Firebase App Hosting → projectname.charlies.bot
API endpoints    → TanStack server functions (createServerFn — same deploy)
Triggers/cron    → Cloud Functions    (separate deploy, event-driven)
Data             → Firestore          (free tier)
Auth             → Firebase Auth      (when needed)
DNS              → Cloud DNS          (*.charlies.bot)
```

The skill exists to remove "where does this go?" decisions, not to add ceremony. Conventions are written, not enforced — solo dev, not enterprise.

## MCP Integration

Two MCP servers cover the workflow. Use them proactively — don't do things manually.

**Firebase MCP** — project lifecycle, data, auth, hosting:

- Use `firebase_create_project` + `firebase_init` for new projects.
- Use `firebase_get_sdk_config` to get Firebase config — never copy-paste from console.
- Use `firebase_get_security_rules` to read existing rules.
- Use `firebase_read_resources` to inspect any `firebase://` URLs.
- Use `firebase_get_environment` first to understand the active project context.
- Note: Firebase MCP does not support App Hosting backend creation. Use the CLI command `firebase apphosting:backends:create` instead. **Always tell the user before running this command** — it opens the browser for a one-time GitHub connection via Developer Connect.

**gcloud MCP** — DNS and escape hatch:

- Use `run_gcloud_command` for Cloud DNS subdomain setup (`projectname.charlies.bot`).
- Use `run_gcloud_command` for anything the specialized MCPs don't cover.
- Use `run_gcloud_command` for Cloud Run deploys (rare escape hatch).

## Do Not

- **No JSX in route files.** Route files are wiring only — they hold `createFileRoute()` config (component pointer, `validateSearch`, `loader`, `beforeLoad`, error/pending) and import the page component from `features/<name>/components/`. If you find yourself writing JSX in `src/routes/`, you're in the wrong file.
- **No Next.js patterns.** No `'use server'` directive idioms, no app-router thinking, no `getServerSideProps`. Server boundaries cross via `createServerFn`, explicitly.
- **No Redux, Zustand, Jotai.** TanStack Store covers shared client state. `useState`/`useReducer` for local. Most side projects need neither.
- **No React Hook Form, no SWR, no Axios, no raw fetch in components.** TanStack Form for forms, TanStack Query for async data, server functions for the server boundary.
- **No Tailwind, Sass, CSS-in-JS, or CSS frameworks.** CSS Modules + modern CSS (nesting, `:has()`, container queries, `@layer`).
- **No Vercel, Netlify, Cloudflare hosting.** Firebase App Hosting only — everything stays in one console.
- **No third-party libraries without asking.** The TanStack family + Firebase + Zod cover most needs. Explain what's missing first.
- **No open Firestore security rules.** Lock down from day one, even for prototypes. Validate with MCP before deploying.
- **No deploy without subdomain configured.** Every project gets `projectname.charlies.bot`. No exceptions.
- **No Firebase Hosting (classic).** Firebase App Hosting ONLY. Do not run `firebase deploy` for hosting. App Hosting is git-push only and configured via `apphosting.yaml`.
- **No Cloud Run unless Cloud Functions genuinely can't handle it.** Server functions handle API endpoints, Cloud Functions handle triggers and cron. Cloud Run is the rare escape hatch.
- **No barrel files (`index.ts` re-exports).** Vite tree-shaking gets confused. Direct imports only.
- **No editing `routeTree.gen.ts`.** It's auto-generated by the `tanstackStart` Vite plugin during dev — gitignored.
- **No `app.config.ts` or Vinxi references.** TanStack Start is Vite-only. Config lives in `vite.config.ts`.

## Tech Stack

| Concern         | Choice                                                          |
| --------------- | --------------------------------------------------------------- |
| Framework       | TanStack Start (latest, Vite-only)                              |
| Routing         | TanStack Router (file-based, type-safe)                         |
| Server state    | TanStack Query (mandatory for async)                            |
| Server endpoints| TanStack server functions (`createServerFn`)                    |
| Local state     | `useState` / `useReducer`                                       |
| Shared state    | TanStack Store (only when shared across distant trees)          |
| Forms           | TanStack Form (when forms get nontrivial)                       |
| Validation      | Zod (mandatory — search params, server fn input, Firestore docs)|
| Hosting         | Firebase App Hosting (git-push deploys)                         |
| API endpoints   | Server functions (on App Hosting)                               |
| Triggers/cron   | Cloud Functions for Firebase                                    |
| Database        | Firestore (free tier focus)                                     |
| Auth            | Firebase Auth (when needed)                                     |
| DNS             | Cloud DNS (`*.charlies.bot`)                                    |
| CSS             | CSS Modules + modern CSS                                        |
| Package manager | npm                                                             |
| Email           | sudo@charlies.bot (Google Workspace)                            |
| Testing         | Vitest                                                          |
| Linting         | ESLint (flat config)                                            |
| Formatting      | Prettier                                                        |

## Project Structure (Summary)

For the full tree and the Ares parallel, see `references/ARCHITECTURE.md`. Quick version:

```
src/
├── routes/                    # Nav graph (Ares: app/navigation/)
├── features/<name>/           # Feature owns its UI + data + types (Ares: features/<name>/)
│   ├── data.ts                # Server fns + queryOptions + key factory
│   ├── types.ts               # Zod schemas + TS types
│   └── components/
├── components/                # Shared UI (extract on 2+ feature reuse)
├── lib/                       # Cross-cutting infra (Ares: :core)
│   ├── firebase.ts            # Client SDK
│   ├── firebase-admin.ts      # Admin SDK (server-only)
│   └── query-client.ts
└── styles/                    # reset.css, tokens.css, globals.css
```

**File naming:** kebab-case files, PascalCase exports. `feed-page.tsx` exports `FeedPage`. Hooks: `use-feed.ts` exports `useFeed`.

**"Where does this go?"**
| If it's...                              | Put it in...                              |
| --------------------------------------- | ----------------------------------------- |
| Route registration (URL, loader, guard) | `src/routes/...`                          |
| The actual screen/page component        | `src/features/<name>/components/`         |
| Feature data layer (queries, server fns)| `src/features/<name>/data.ts`             |
| Feature types/schemas                   | `src/features/<name>/types.ts`            |
| A component used by 2+ features         | `src/components/`                         |
| Cross-cutting infrastructure            | `src/lib/`                                |
| Design tokens or global CSS             | `src/styles/`                             |

## Routes — Wiring Only

A route file holds `createFileRoute()` config and imports the page from `features/`. No JSX.

```tsx
// src/routes/_authed/feed.tsx
import { createFileRoute } from '@tanstack/react-router';
import { z } from 'zod';
import { FeedPage } from '~/features/feed/components/feed-page';
import { feedQueryOptions } from '~/features/feed/data';

export const Route = createFileRoute('/_authed/feed')({
  component: FeedPage,
  validateSearch: z.object({ filter: z.string().optional() }),
  loader: ({ context }) => context.queryClient.ensureQueryData(feedQueryOptions()),
});
```

## State Management

**Default async pattern:** route `loader` calls `queryClient.ensureQueryData(...)`, the page component reads via `useSuspenseQuery(...)`. No manual `isLoading` ladders.

```tsx
// src/features/feed/data.ts
import { queryOptions } from '@tanstack/react-query';
import { createServerFn } from '@tanstack/start';
import { z } from 'zod';

export const feedKeys = {
  all: ['feed'] as const,
  detail: (id: string) => ['feed', id] as const,
};

export const getFeed = createServerFn({ method: 'GET' })
  .validator(z.object({ limit: z.number().default(20) }))
  .handler(async ({ data }) => {
    const { db } = await import('~/lib/firebase-admin');
    const snap = await db.collection('articles').limit(data.limit).get();
    return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  });

export const feedQueryOptions = () =>
  queryOptions({
    queryKey: feedKeys.all,
    queryFn: () => getFeed({ data: { limit: 20 } }),
  });
```

```tsx
// src/features/feed/components/feed-page.tsx
import { useSuspenseQuery } from '@tanstack/react-query';
import { feedQueryOptions } from '../data';

export function FeedPage() {
  const { data: articles } = useSuspenseQuery(feedQueryOptions());
  return <ul>{articles.map((a) => <li key={a.id}>{a.title}</li>)}</ul>;
}
```

**Server function naming:** verb-noun. `getFeed`, `createPost`, `deletePost`, `updateUser`. Mark server-only modules `*.server.ts` when they import the Admin SDK directly without `createServerFn` wrapping (rare — most code uses `createServerFn`).

**Local state:** `useState` / `useReducer`. Don't reach for Store unless 2+ distant components need to share writable state.

**Firestore real-time listeners:** clean up via `useEffect` return:

```tsx
useEffect(() => {
  const unsub = onSnapshot(query, (snap) => setItems(snap.docs.map((d) => d.data())));
  return unsub;
}, []);
```

## CSS Conventions

CSS Modules per component. The component file imports its sibling `.module.css`:

```tsx
// src/features/feed/components/feed-page.tsx
import styles from './feed-page.module.css';
export function FeedPage() {
  return <article className={styles.article}>...</article>;
}
```

```css
/* feed-page.module.css */
.article {
  padding: var(--spacing-md);
  &:has(img) { padding-block: var(--spacing-lg); }
}
```

**Global `src/styles/`** contains only:
- `reset.css` — modern CSS reset
- `tokens.css` — design tokens (CSS custom properties)
- `globals.css` — imports the above + base typography

In component CSS, use native nesting, `:has()`, container queries, `@layer`. Semantic class names — no utility classes.

## Firebase Setup (on demand)

When a project needs Firebase (Firestore, Auth, Cloud Functions, etc.):

1. `npm install firebase` — install the Firebase JS SDK directly.
2. Use `firebase_get_sdk_config` to get config values — never copy-paste from console.
3. Store the config in `.env.local` (gitignored) as `VITE_FIREBASE_*` variables.
4. `src/lib/firebase.ts` is the single client-side entry point — feature code imports `auth`, `db` from here, never raw Firebase SDK.

```ts
// src/lib/firebase.ts
import { initializeApp, getApps } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// HMR-safe: reuse the existing app on hot reload.
const app =
  getApps()[0] ??
  initializeApp({
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: import.meta.env.VITE_FIREBASE_APP_ID,
  });

export const auth = getAuth(app);
export const db = getFirestore(app);
```

For server functions that need privileged access (writing to admin-only collections, reading any user's data), use `src/lib/firebase-admin.ts` with the Admin SDK. Server functions import from `firebase-admin`; client components import from `firebase`. Never the other way around.

## Firestore Conventions

**Security rules are locked down from day one** — even for prototypes. New projects start with `assets/firestore.rules` (deny all). As features are built, open access per-collection using the auth-owns-data pattern. Use `firebase_get_security_rules` to verify existing rules before deploying. Deploy with `firebase deploy --only firestore:rules`.

**Auth-owns-data pattern** (default for most features):

```
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
match /users/{userId}/{subcollection=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

**Public-read / authenticated-write** (for shared content):

```
match /posts/{postId} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

## Backend Logic

App Hosting runs Node — so you already have a backend. Use **server functions** (`createServerFn`) as the default for API endpoints. They deploy with your app, share the same App Hosting instance, and give typed RPC with Zod validation at the boundary.

Use **Cloud Functions** only when the logic needs to run independently of the app:

- **Firestore triggers** — react to document creates, updates, deletes
- **Auth triggers** — react to user creation, deletion
- **Scheduled tasks** — cron jobs (cleanup, aggregation, notifications)
- **Reusable services across apps** — e.g., a shared OAuth service that multiple charlies.bot apps call

Keep functions small and focused — one function per concern. Deploy with `firebase deploy --only functions`. Debug with `mcp__plugin_firebase_firebase__functions_get_logs`.

## Auth

See `references/AUTH.md` for the full pattern. Quick version: auth state lives in **TanStack Router context**, not React Context. The `_authed/route.tsx` layout uses `beforeLoad` to redirect unauthed users — guards run before the route renders, no flash of protected UI. Components read the user via `useRouteContext()`.

## Testing

**Vitest** is the default test runner (`npm test`). Tests live next to the code they test (e.g., `feed-page.test.tsx` alongside `feed-page.tsx`).

- Use Vitest's `expect` API; React Testing Library for component tests.
- Server functions can be unit-tested by importing them directly — they're plain async functions outside the request lifecycle.
- Mock Firebase via Vitest's module mocking when needed; prefer integration tests against the Firestore emulator for repository-level code.

## Linting & Formatting

**ESLint** with flat config (`eslint.config.js`). The scaffold script sets up `@eslint/js` + `typescript-eslint` + the React plugins. Run with `npm run lint`.

**Prettier** for formatting. The scaffold drops in `.prettierrc.json` and `eslint-config-prettier` to avoid rule conflicts.

Conventions in the skill (no cross-feature imports, `firebase-admin` only on server) are written rules, not enforced lint failures. Solo dev — discipline > automation overhead.

## Scaffolding a New Project

Use the bundled script to scaffold a TanStack Start project with all conventions baked in:

```bash
./scripts/new-project.sh <project-name>
```

The script runs `@tanstack/create-start` (the official TanStack scaffolder, currently alpha), then drops in the locked configs (`apphosting.yaml`, `lib/firebase.ts`, `tokens.css`, `__root.tsx`, `eslint.config.js`, `.env.example`, Firestore rules, CSS reset, Prettier config) and installs `firebase`, `zod`, and `firebase-admin`. The `apphosting.yaml` is created upfront with placeholders, but **don't create a Firebase project, run `firebase apphosting:backends:create`, or configure DNS until the user asks for the feature that needs them**. Just `cd` in and start with `npm run dev`.

## Deploying

All projects use Firebase App Hosting with git-push deploys:

1. **Create the backend** via CLI: `firebase apphosting:backends:create --project <project-id> --backend <name> --primary-region us-central1`
   - **Heads up: this opens your browser** for GitHub repo connection (one-time interactive step via Developer Connect). Tell the user before running the command.
2. **Create `apphosting.yaml`** in the project root (the scaffold does this — see DEPLOYMENT.md for the runtime config)
3. **Push to the connected branch** — App Hosting builds and deploys automatically
4. **Triggers/cron** → Cloud Functions: `firebase deploy --only functions`
5. **Custom containers (rare)** → Cloud Run via `run_gcloud_command`

Every project deploys as `projectname.charlies.bot`. See `references/DEPLOYMENT.md` for DNS and detailed instructions.
