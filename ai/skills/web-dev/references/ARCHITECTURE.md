# Project Architecture

Follows Angular's official style guide: **organize by feature, not by type**. For coding patterns (signals, `inject()`, `OnPush`, control flow, naming), defer to the Angular CLI MCP via `get_best_practices`.

Uses the **2025 naming convention** (Angular v20+ default):

- **Files:** `dashboard.ts` not `dashboard.component.ts`, `auth.ts` not `auth.service.ts`.
- **Classes:** Drop type suffixes. `Dashboard` not `DashboardComponent`. Use role-based names for services: `Auth`, `UserApi`, `CartClient` — not `AuthService`.

## Folder Structure

```text
src/app/
├── core/                  # App-wide infrastructure
│   ├── auth/              #   Auth service, guard
│   ├── layout/            #   Header, footer, shell
│   └── interceptors/      #   HTTP interceptors
├── dashboard/             # Feature (top-level, self-contained)
│   ├── dashboard.ts       #   Page component (external template — large)
│   ├── dashboard.html
│   ├── dashboard.css
│   ├── dashboard.routes.ts
│   ├── dashboard-stats.ts #   Sub-component (inline template — small)
│   └── dashboard-chart.ts #   Sub-component (inline template — small)
├── profile/               # Feature
├── ui/                    # Reusable dumb components (on demand)
│   ├── button.ts
│   └── card.ts
├── app.config.ts          # Global providers
├── app.routes.ts          # Root routing (lazy-loads features)
└── app.ts                 # Root component
```

**Templates:** Inline `template` + `styles` for small components (single file). External `templateUrl` + `styleUrl` for large ones.

## Rules

### `core/` — Infrastructure

- Auth, layout, interceptors, guards, injection tokens.
- All services use `providedIn: 'root'`.
- Not a feature — no routes of its own.

### Features — Top-Level Directories

- Each feature is a top-level folder (`dashboard/`, `profile/`, `settings/`).
- Self-contained: owns its components, services, and routes.
- Lazy-loaded via `loadComponent` (single routes) or `loadChildren` (route groups).

### `ui/` — Reusable Components (On Demand)

- Created when a component is needed by 2+ features.
- No service injections. `input()` and `output()` only.
- Start components in their feature folder; extract to `ui/` when reused.

## "Where Does This Go?"

| If it's...                              | Put it in...                         |
| --------------------------------------- | ------------------------------------ |
| App-wide service, guard, or interceptor | `core/`                              |
| App shell (header, footer, sidebar)     | `core/layout/`                       |
| A page or domain-specific flow          | Top-level feature folder             |
| A sub-component for one feature         | Same feature folder (flat, prefixed) |
| A component used by 2+ features         | `ui/`                                |

## State Management

See the State Management section in SKILL.md — it covers `linkedSignal()`, `httpResource()`, `resource()`, and `effect()` conventions.
