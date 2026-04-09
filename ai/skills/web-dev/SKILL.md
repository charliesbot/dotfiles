---
name: web-dev
description: Use this skill whenever the user wants to build, modify, deploy, or maintain ANY web app or side project — even if they don't say "Angular" or "Firebase" explicitly. Trigger on new project setup, adding features/pages/components, refactoring code to signals, Firebase deploy, Firestore rules/security, Cloud Functions, Google sign-in/auth, subdomain setup (*.charlies.bot), CSS styling, Vitest/testing, ESLint/Prettier/linting, ng lint, ng generate, ng serve, or any mention of a charlies.bot project. Also trigger when the user asks to "build an app", "start a project", "add a page", "deploy my app", "fix my tests", or "lock down rules". If in doubt and the task involves web development, use this skill.
---

You are working on a web side project following Charlie's Angular + Firebase conventions. Every project deploys as a subdomain of `charlies.bot`.

- Read `references/ARCHITECTURE.md` when deciding where to place new files or creating a new feature folder.
- Read `references/DEPLOYMENT.md` before any deploy, DNS, or Cloud Functions work.
- Read `references/AUTH.md` when adding Firebase Auth to a project for the first time.

## Core Principles

Every side project is `projectname.charlies.bot`. Firebase handles everything — hosting, backend, data, auth. Free tier first. Zero setup decisions. **Firebase App Hosting** is used for all projects.

```
All projects     → Firebase App Hosting → projectname.charlies.bot
API endpoints    → Angular server routes (same deploy, zero extra infra)
Triggers/cron    → Cloud Functions    (separate deploy, event-driven)
Data             → Firestore          (free tier)
Auth             → Firebase Auth      (when needed)
DNS              → Cloud DNS          (*.charlies.bot)
```

## MCP Integration

Three MCP servers cover the full workflow. Use them proactively — don't do things manually.

**Angular CLI MCP** — for patterns this skill doesn't cover:

- Use `get_best_practices` when working with Angular APIs not covered in this skill (e.g., animations, i18n, service workers). Skip it for signals, OnPush, standalone, routing — those are already defined here.
- Use `find_examples` when unsure about a specific modern Angular pattern.
- Use `search_documentation` for Angular API details.
- Use `angular-cli__list_projects` to discover workspace structure.

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

- **No Zone.js** — use Zoneless change detection (`provideZonelessChangeDetection()`). Avoid `NgZone` and RxJS `async` pipes where Signals are viable.
- **No Tailwind, Sass, CSS-in-JS, or CSS frameworks** — modern CSS with Angular component scoping is enough.
- **No NgModules** — standalone components only. The entire codebase uses standalone.
- **No Vercel, Netlify, or non-Google hosting** — Firebase ecosystem only. Everything stays in one console.
- **No third-party libraries without asking** — the current stack covers most needs. Explain what's missing first.
- **No open Firestore security rules** — lock down from day one, even for prototypes. Validate with MCP before deploying.
- **No deploy without subdomain configured** — every project gets `projectname.charlies.bot`. No exceptions.
- **No RxJS for simple state** — use signals. RxJS only for complex async streams (WebSocket feeds, debounced search, combineLatest patterns).
- **No Firebase Hosting (classic)** — Firebase App Hosting ONLY. Do not run `firebase deploy` for hosting. App Hosting is git-push only and configured via `apphosting.yaml`.
- **No Cloud Run unless Cloud Functions genuinely can't handle it** — Angular server routes handle API endpoints, Cloud Functions handle triggers and cron. Cloud Run is the rare escape hatch.

## Tech Stack

| Concern         | Choice                                                |
| --------------- | ----------------------------------------------------- |
| Framework       | Angular 21+ (Signals-first, **Zoneless**, standalone) |
| Hosting         | Firebase App Hosting (git-push deploys)               |
| API endpoints   | Angular server routes (on App Hosting)                |
| Triggers/cron   | Cloud Functions for Firebase                          |
| Database        | Firestore (free tier focus)                           |
| Auth            | Firebase Auth (when needed)                           |
| DNS             | Cloud DNS (`*.charlies.bot`)                          |
| CSS             | Modern CSS (component-scoped) + CSS reset             |
| Package manager | npm                                                   |
| Email           | sudo@charlies.bot (Google Workspace)                  |
| Testing         | **Vitest** (Angular default)                          |
| Linting         | ESLint via `angular-eslint`                           |
| Formatting      | Prettier                                              |

## Project Structure

Use `ng generate` to create all code — it handles file placement, naming, and boilerplate. Angular 21 projects use **Zoneless** by default and the **2025 file naming convention** (`dashboard.ts` not `dashboard.component.ts`).

- **`core/`** — app-wide infrastructure (auth, layout, interceptors). Not a feature.
- **Features at top level** — each feature is its own directory (`dashboard/`, `profile/`). Self-contained with own routes, components, and services.
- **`ui/`** — reusable dumb components, created on demand when shared across 2+ features.

```bash
ng generate component dashboard            # Feature component
ng generate component ui/button            # Reusable UI component
ng generate service core/auth              # Global service
```

**"Where does this go?"**
`core/` for infrastructure (auth, layout, interceptors). Top-level folder for features. `ui/` for components reused across features. Start in the feature, extract to `ui/` when reused.

## Component Pattern

**Inline templates for small components** (Angular best practice), external files for large ones:

```typescript
// Small component — inline template + styles (single file)
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: "app-dashboard-stats",
  template: `
    <div class="stats">
      @for (stat of stats(); track stat.label) {
        <span>{{ stat.label }}: {{ stat.value }}</span>
      }
    </div>
  `,
  styles: `
    .stats {
      display: flex;
      gap: 1rem;
    }
  `,
})
export class DashboardStats {
  readonly stats = input.required<Stat[]>();
}

// Large component — external template + styles
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: "app-dashboard",
  templateUrl: "./dashboard.html",
  styleUrl: "./dashboard.css",
})
export class Dashboard {
  private router = inject(Router);

  items = httpResource<Item[]>(() => "/api/items");
  itemCount = computed(() => this.items.value()?.length ?? 0);
  searchQuery = signal("");
  selectedCategory = linkedSignal(
    () => this.items.value()?.[0]?.category ?? "all",
  );
}
```

Components use signals for all reactive state. Use built-in control flow (`@if`, `@for`, `@switch`).

## State Management

**Signals by default.** Use Angular signals (`signal()`, `computed()`, `linkedSignal()`, `effect()`) for all component and service state. Use `computed()` for read-only derived state, `linkedSignal()` for writable derived state (e.g., a selection that resets when its source changes), and `effect()` sparingly as a last resort for side effects. Angular 21 favors **Zoneless** change detection — avoid `NgZone` and manual change detection calls.

**Async data loading:** Use `httpResource()` (experimental) for reactive HTTP data fetching instead of manual `isLoading`/`error`/`data` signal triplets. It wraps `HttpClient` and exposes status and response as signals. For non-HTTP async data, use `resource()`. Requires `provideHttpClient()` in `app.config.ts` providers.

**Firestore real-time listeners:** Use `DestroyRef` to clean up `onSnapshot` subscriptions. Even if the store service is `providedIn: 'root'`, the **component** that starts listening should own the cleanup — otherwise navigating away and back creates duplicate listeners:

```typescript
// In the component that starts listening
private store = inject(BookmarkStore);
private destroyRef = inject(DestroyRef);

ngOnInit(): void {
  const unsub = this.store.listen();
  this.destroyRef.onDestroy(() => unsub());
}
```

The store's `listen()` method returns the unsubscribe function so the caller controls the lifecycle. Root singleton services don't need `DestroyRef` internally — they live for the app lifetime.

## CSS Conventions

Component-scoped modern CSS via Angular's default `ViewEncapsulation.Emulated`. Small components use inline `styles`; large components use external `.css` files.

**Global `styles.css`** contains only:

- CSS reset
- Custom properties (design tokens: colors, spacing, typography)
- Base typography

**In component CSS**, use:

- Native CSS nesting
- `:has()` selector
- Container queries
- `@layer` for cascade management
- Semantic class names — no utility classes

No Tailwind, no Sass, no CSS-in-JS. Modern CSS is enough.

## Firebase Setup (on demand)

When a project needs Firebase (Firestore, Auth, Cloud Functions, etc.):

1. `npm install firebase` — install the Firebase JS SDK directly. No `@angular/fire` — it's an unnecessary abstraction with standalone components and `inject()`.
2. Use `firebase_get_sdk_config` to get config values — never copy-paste from console.
3. Create a `core/firebase.ts` service that wraps `initializeApp()` and exposes `Firestore`, `Auth`, etc. as injectable singletons. All feature services inject from this wrapper — never import raw Firebase SDK in feature code.

```typescript
// core/firebase.ts — the single Firebase entry point
import { Injectable } from "@angular/core";
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { environment } from "../../environments/environment";

@Injectable({ providedIn: "root" })
export class Firebase {
  private app = initializeApp(environment.firebase);
  readonly db = getFirestore(this.app);
  readonly auth = getAuth(this.app);
}
```

Store the config from `firebase_get_sdk_config` in `src/environments/environment.ts` under a `firebase` key.

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

App Hosting runs Angular SSR on Node.js — so you already have a backend. Use **Angular server routes** as the default for API endpoints. They deploy with your app (zero extra infra) and share the same App Hosting instance.

Use **Cloud Functions** only when the logic needs to run independently of the app:

- **Firestore triggers** — react to document creates, updates, deletes
- **Auth triggers** — react to user creation, deletion
- **Scheduled tasks** — cron jobs (cleanup, aggregation, notifications)
- **Reusable services across apps** — e.g., a shared OAuth service that multiple charlies.bot apps call

Keep functions small and focused — one function per concern. Deploy with `firebase deploy --only functions`. Debug with `mcp__plugin_firebase_firebase__functions_get_logs`.

## Testing

**Vitest** is the default test runner (`ng test`). Tests live next to the code they test (e.g., `dashboard.spec.ts` alongside `dashboard.ts`).

- Use `TestBed` for component tests with `provideHttpClient()` and `provideHttpClientTesting()`.
- Test `httpResource` via `HttpTestingController` — flush requests and assert on signal values.
- Test signals directly: update with `.set()` / `.update()`, assert with `()`.
- Use `fixture.componentRef.setInput()` for signal inputs.

```typescript
TestBed.configureTestingModule({
  providers: [provideHttpClient(), provideHttpClientTesting()],
});
const mockBackend = TestBed.inject(HttpTestingController);
// ... flush requests, assert signal values
```

## Linting & Formatting

**ESLint** is added via `ng add angular-eslint` (flat config, `eslint.config.js`). The scaffold script handles this. Run with `ng lint`.

**Prettier** is added manually for formatting. Install with `npm install prettier --save-dev` and add a `.prettierrc` config. Use `eslint-config-prettier` to avoid rule conflicts.

## Scaffolding a New Project

Use the bundled script to create a lean Angular project:

```bash
./scripts/new-project.sh <project-name>
```

This creates an Angular project with CSS reset, routing, SSR, and git initialized. Nothing else — don't create a Firebase project, install the Firebase SDK, set up DNS, or configure `apphosting.yaml` until the user asks for a specific feature that needs them. Just `cd` in and start building with `ng serve`.

## Deploying

All projects use Firebase App Hosting with git-push deploys:

1. **Create the backend** via CLI: `firebase apphosting:backends:create --project <project-id> --backend <name> --primary-region us-central1`
   - **Heads up: this opens your browser** for GitHub repo connection (one-time interactive step via Developer Connect). Tell the user before running the command.
2. **Create `apphosting.yaml`** in the project root (see DEPLOYMENT.md for config)
3. **Push to the connected branch** — App Hosting builds and deploys automatically
4. **Triggers/cron** → Cloud Functions: `firebase deploy --only functions`
5. **Custom containers (rare)** → Cloud Run via `run_gcloud_command`

Every project deploys as `projectname.charlies.bot`. See `references/DEPLOYMENT.md` for DNS and detailed instructions.

## Reference

For deployment, hosting, and infrastructure details, read `references/DEPLOYMENT.md`.
