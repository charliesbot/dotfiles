# Project Architecture

Web side projects mirror the architecture of Charlie's Android app at `~/projects/ares`. Where Ares uses Gradle modules to enforce boundaries (`app/`, `:core`, `:features:<name>`), the web codebase uses folder conventions. The mental model is the same: **`routes/` is the nav graph, `features/` owns each user journey, `lib/` is the shared infrastructure.**

This document is the long-form companion to SKILL.md. SKILL.md tells you _what_ to do; this tells you _where_ and _why_.

## Foundational Conventions

- **Bulletproof React `features/`** for feature organization (https://github.com/alan2207/bulletproof-react)
- **TanStack Router file-based routing** for the nav graph (`src/routes/`)
- **Unidirectional flow:** shared (`lib/`, `components/`) → features → routes. Features never import from other features.
- **No barrel files.** Vite tree-shaking gets confused; direct imports only.
- **kebab-case files, PascalCase exports.** `feed-page.tsx` exports `FeedPage`. `use-feed.ts` exports `useFeed`.

## Full Tree

```
ares-web/                            # example project name
├── apphosting.yaml                  # Firebase App Hosting runtime config
├── firebase.json                    # Firestore + Functions deploy config
├── firestore.rules                  # Locked from day one
├── vite.config.ts                   # Vite + tanstackStart plugin
├── eslint.config.js                 # Flat config
├── .prettierrc.json
├── .env.local                       # VITE_FIREBASE_* (gitignored)
├── package.json
├── tsconfig.json                    # Path alias ~/* → src/*
│
├── functions/                       # Cloud Functions (only when needed)
│   ├── package.json
│   └── src/
│       └── index.ts
│
└── src/
    ├── client.tsx                   # Client entry            [Ares: MainActivity]
    ├── router.tsx                   # Router instance config
    ├── routeTree.gen.ts             # AUTO-GENERATED, gitignored
    │
    ├── routes/                      # Nav graph              [Ares: app/navigation/]
    │   ├── __root.tsx               # App shell + providers
    │   ├── index.tsx                # /
    │   │
    │   ├── auth/
    │   │   └── sign-in.tsx          # /auth/sign-in
    │   │
    │   └── _authed/                 # Pathless auth-guard layout
    │       ├── route.tsx            # beforeLoad redirects unauthed
    │       ├── feed.tsx             # /feed              [Ares: FeedScreen.kt registration]
    │       ├── feed.$id.tsx         # /feed/:articleId   [Ares: ArticleScreen.kt registration]
    │       └── settings.tsx
    │
    ├── features/                    # Feature logic        [Ares: features/<name>/]
    │   ├── feed/
    │   │   ├── data.ts              # queryOptions + key factory + server fns
    │   │   ├── types.ts             # Zod schemas + TS types  [Ares: domain/model]
    │   │   └── components/
    │   │       ├── feed-page.tsx    # The screen           [Ares: FeedScreen.kt]
    │   │       ├── feed-page.module.css
    │   │       └── article-item.tsx
    │   ├── article/
    │   └── auth/
    │
    ├── components/                  # Shared design system  [Ares: core/ui/components/]
    │   ├── button.tsx
    │   ├── button.module.css
    │   └── bottom-sheet.tsx         #                       [Ares: MorphingBottomSheet]
    │
    ├── lib/                         # Cross-cutting infra   [Ares: :core]
    │   ├── firebase.ts              # Client SDK            [Ares: FirebaseModule (DI)]
    │   ├── firebase-admin.ts        # Admin SDK (server-only)
    │   ├── query-client.ts
    │   └── utils/
    │
    └── styles/                      #                       [Ares: core/ui/theme/]
        ├── reset.css
        ├── tokens.css               # CSS custom properties [Ares: Theme.kt + colors.xml]
        └── globals.css              # Imports + base typography
```

## Ares → Web Concept Mapping

| Ares (Android)                         | Web (TanStack Start)                                  | Notes                                        |
| -------------------------------------- | ----------------------------------------------------- | -------------------------------------------- |
| `app/` Gradle module                   | `src/routes/__root.tsx` + `client.tsx` + `router.tsx` | App entry & shell                            |
| `app/navigation/AppNavigation.kt`      | `src/routes/` (file tree)                             | Folder structure **is** the nav graph        |
| `app/ui/theme/`                        | `src/styles/tokens.css`                               | CSS custom properties replace `Theme.kt`     |
| `:core` Gradle module                  | `src/lib/` + `src/components/` + `src/styles/`        | Shared infra, no module boundary             |
| `core/ui/components/`                  | `src/components/`                                     | Shared design-system primitives              |
| `core/data/repository/`                | Server functions in `features/<name>/data.ts`         | Feature owns its data layer                  |
| `core/data/local/database/`            | _(none by default — Firestore client cache)_          | Add IndexedDB only if offline-first          |
| `core/data/remote/dto/`                | Zod schemas in `features/<name>/types.ts`             | Validation + types in one                    |
| `core/domain/model/`                   | TS types in `features/<name>/types.ts`                | Co-located, not a separate layer             |
| `core/domain/usecase/`                 | `queryOptions` + custom hooks in `data.ts`            | Use cases become Query options               |
| `core/di/` (Koin modules)              | _(none — JS imports)_                                 | DI is implicit; no Koin needed               |
| `core/common/`                         | `src/lib/utils/`                                      | Shared helpers                               |
| `:htmlparser` Gradle module            | `src/lib/<utility>/` (or top-level if substantial)    | Utility lives in `lib/`                      |
| `features/feed/` Gradle module         | `src/routes/_authed/feed.tsx` + `src/features/feed/`  | Feature = route registration + feature logic |
| `FeedScreen.kt` (composable)           | `src/features/feed/components/feed-page.tsx`          | The actual screen                            |
| Route registration (`composable<...>`) | `src/routes/_authed/feed.tsx`                         | Wiring only                                  |
| `FeedViewModel.kt`                     | Split: `data.ts` (server cache) + UI hooks            | Don't put it all in one "viewmodel" file     |
| `feed/components/ArticleItem.kt`       | `src/features/feed/components/article-item.tsx`       | Feature-private UI                           |
| `feed/di/FeedModule.kt`                | _(none)_                                              | Just import what you need                    |

## Layer Parallel (Clean Architecture)

| Ares layer                                      | Web equivalent                        | Lives in                                       |
| ----------------------------------------------- | ------------------------------------- | ---------------------------------------------- |
| **Domain** (models, use cases, repo interfaces) | TS types + Zod schemas + queryOptions | `features/<name>/types.ts` + `data.ts`         |
| **Data** (repositories, local DB, remote DTOs)  | Server functions + Firebase wrapper   | `features/<name>/data.ts` + `lib/firebase*.ts` |
| **UI** (Compose screens, ViewModels)            | React components + hooks              | `features/<name>/components/` + `routes/`      |
| **DI** (Koin modules)                           | JS imports                            | _(no equivalent needed)_                       |

## Routes — Wiring Only

A route file holds `createFileRoute()` config and imports the page from `features/`. **No JSX in route files.** This is the same separation Ares enforces between `AppNavigation.kt` (declares destinations) and `FeedScreen.kt` (the actual screen).

What's allowed in a route file:

- `createFileRoute()` config
- `validateSearch` (Zod schema for URL params)
- `loader` (data prefetch via `queryClient.ensureQueryData`)
- `beforeLoad` (auth or other route-level guards)
- `errorComponent`, `pendingComponent` (route-level UI for loading/error states — these are tiny references, not full screens)
- imports of the page component from `features/`

```tsx
// src/routes/_authed/feed.tsx
import { createFileRoute } from "@tanstack/react-router";
import { z } from "zod";
import { FeedPage } from "~/features/feed/components/feed-page";
import { feedQueryOptions } from "~/features/feed/data";

export const Route = createFileRoute("/_authed/feed")({
  component: FeedPage,
  validateSearch: z.object({ filter: z.string().optional() }),
  loader: ({ context }) =>
    context.queryClient.ensureQueryData(feedQueryOptions()),
});
```

If you find yourself writing JSX in `routes/`, the UI belongs in `features/<name>/components/`.

## Feature Internals (`data.ts` pattern)

Each feature folder contains:

- **`data.ts`** — server functions (`createServerFn`), `queryOptions()` factories, query key factory. The feature's data layer.
- **`types.ts`** — Zod schemas + TypeScript types derived from them.
- **`components/`** — feature-private UI: the page component plus any sub-components only this feature uses.

Optional (add when needed, not preemptively):

- **`hooks.ts`** — UI/component hooks that don't fit Query (rare for side projects). E.g., a `useScrollRestore()` specific to the feature.
- **`store.ts`** — TanStack Store for shared writable state across distant components within the feature. Most features don't need it.

### Server function + queryOptions example

```ts
// src/features/feed/data.ts
import { queryOptions } from "@tanstack/react-query";
import { createServerFn } from "@tanstack/start";
import { z } from "zod";
import { Article } from "./types";

export const feedKeys = {
  all: ["feed"] as const,
  detail: (id: string) => ["feed", id] as const,
};

export const getFeed = createServerFn({ method: "GET" })
  .validator(z.object({ limit: z.number().default(20) }))
  .handler(async ({ data }) => {
    const { db } = await import("~/lib/firebase-admin");
    const snap = await db.collection("articles").limit(data.limit).get();
    return snap.docs.map((d) => Article.parse({ id: d.id, ...d.data() }));
  });

export const feedQueryOptions = () =>
  queryOptions({
    queryKey: feedKeys.all,
    queryFn: () => getFeed({ data: { limit: 20 } }),
  });
```

### types.ts example

```ts
// src/features/feed/types.ts
import { z } from "zod";

export const Article = z.object({
  id: z.string(),
  title: z.string().min(1),
  url: z.string().url(),
  publishedAt: z.coerce.date(),
  tags: z.array(z.string()).default([]),
});

export type Article = z.infer<typeof Article>;
```

### Page component example

```tsx
// src/features/feed/components/feed-page.tsx
import { useSuspenseQuery } from "@tanstack/react-query";
import { feedQueryOptions } from "../data";
import { ArticleItem } from "./article-item";
import styles from "./feed-page.module.css";

export function FeedPage() {
  const { data: articles } = useSuspenseQuery(feedQueryOptions());
  return (
    <ul className={styles.list}>
      {articles.map((a) => (
        <ArticleItem key={a.id} article={a} />
      ))}
    </ul>
  );
}
```

## State Strategy

Default async pattern: **route `loader` prefetches via `queryClient.ensureQueryData`, the page reads via `useSuspenseQuery`.** No manual `isLoading` ladders, no `error` triplets.

Where state lives, by question:

| Question                                      | Answer                                           |
| --------------------------------------------- | ------------------------------------------------ |
| Is it from the server / async?                | TanStack Query (via `queryOptions` in `data.ts`) |
| Is it in the URL?                             | Router search params (via `validateSearch`)      |
| Is it shared across distant components?       | TanStack Store (rare — only when truly needed)   |
| Is it local to one component or near-by tree? | `useState` / `useReducer`                        |
| Is it auth state?                             | Router context (set in `__root.tsx`)             |

## Auth — Router Context, Not React Context

Auth state lives in TanStack Router's context, not React Context. The reason is `beforeLoad`: route guards run **before** the route renders, so they can redirect without flashing the protected UI. React Context isn't available in `beforeLoad`.

The flow:

1. `client.tsx` subscribes to `onAuthStateChanged` and reinitializes the router with the current user in context.
2. `__root.tsx` declares the context shape via `createRootRouteWithContext<{ user: User | null }>()`.
3. `_authed/route.tsx` uses `beforeLoad` to redirect when `context.user` is null.
4. Components inside `_authed/` read the user via `useRouteContext()` from a route hook — no Provider needed.

Full example in `references/AUTH.md`.

## CSS Structure

Component-scoped CSS Modules. Each component has a sibling `.module.css`:

```
src/features/feed/components/
├── feed-page.tsx
├── feed-page.module.css
├── article-item.tsx
└── article-item.module.css
```

`src/styles/` contains only:

- **`reset.css`** — modern CSS reset
- **`tokens.css`** — design tokens (CSS custom properties: colors, spacing, typography, radii)
- **`globals.css`** — imports the above + base typography for `body`, `h1`-`h6`, `p`

`__root.tsx` imports `globals.css` once. Component files only import their own `.module.css`. No utility classes, no Tailwind.

## "Where Does This Go?" — Decision Table

| If it's...                                    | Put it in...                      | Promote when...                             |
| --------------------------------------------- | --------------------------------- | ------------------------------------------- |
| URL/route registration, loader, guard         | `src/routes/...`                  | Never — routes stay thin                    |
| The actual screen for a feature               | `src/features/<name>/components/` | Never — screens are feature-owned           |
| Sub-component for one feature                 | `src/features/<name>/components/` | When 2+ features use it → `components/`     |
| Component used by 2+ features                 | `src/components/`                 | Never (this is the destination)             |
| Server function for a feature                 | `src/features/<name>/data.ts`     | When 2+ features use it → `lib/server-fns/` |
| `queryOptions` for a feature                  | `src/features/<name>/data.ts`     | Stays in feature                            |
| Zod schema / TS types for a feature           | `src/features/<name>/types.ts`    | Stays in feature                            |
| Cross-feature utility (date formatting, etc.) | `src/lib/utils/`                  | Stays in lib                                |
| Firebase wrapper, query client, etc.          | `src/lib/`                        | Stays in lib                                |
| Design token (CSS variable)                   | `src/styles/tokens.css`           | Stays                                       |
| Cross-cutting CSS (typography, body styles)   | `src/styles/globals.css`          | Stays                                       |

## What Counts as a "Feature"

A feature is a complete user journey — usually 1-3 related routes, sometimes more. Examples for the imaginary `ares-web`:

- **`feed/`** — feed list + article detail (2 routes, shared data layer)
- **`auth/`** — sign-in flow (1 route)
- **`settings/`** — settings page (1 route, but enough domain logic to warrant its own folder)

A single screen with no real data or logic doesn't need a `features/` folder — keep it in `routes/` until it grows. The promotion threshold is "I'm starting to write feature-specific data fetching, types, or sub-components."

## Generated Files

`src/routeTree.gen.ts` is auto-generated by the `tanstackStart` Vite plugin during dev. It's gitignored. Don't edit it. If imports from it look broken, `npm run dev` regenerates it.
