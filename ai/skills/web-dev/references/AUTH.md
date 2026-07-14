# Firebase Auth

## Setup

1. Enable Google sign-in in Firebase console (authorized domain: `projectname.charlies.bot`)
2. Contact email: sudo@charlies.bot
3. Ensure `src/lib/firebase.ts` exists (see SKILL.md "Firebase Setup" section). Auth uses the same wrapper.

## Strategy: Router Context, Not React Context

Auth state lives in **TanStack Router's context**, not React Context. The reason is `beforeLoad`: route guards run **before** the route renders. If you check auth in a component (via React Context), you've already rendered the protected UI for a frame before redirecting — flash of protected content. `beforeLoad` redirects cleanly because it runs before render.

The flow:

1. `client.tsx` subscribes to `onAuthStateChanged` and rebuilds the router context whenever the user changes.
2. `__root.tsx` declares the context shape via `createRootRouteWithContext<{ user: User | null; queryClient: QueryClient }>()`.
3. `_authed/route.tsx` uses `beforeLoad` to redirect when `context.user` is null.
4. Components inside `_authed/` read the user via `useRouteContext()` from any route hook — no Provider needed.

## client.tsx — wire auth into the router

```tsx
// src/client.tsx
import { hydrateRoot } from "react-dom/client";
import { QueryClient } from "@tanstack/react-query";
import { StartClient, createRouter } from "@tanstack/start";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "~/lib/firebase";
import { routeTree } from "./routeTree.gen";

const queryClient = new QueryClient();

const router = createRouter({
  routeTree,
  context: { user: null, queryClient },
  defaultPreload: "intent",
});

onAuthStateChanged(auth, (user) => {
  // Update context FIRST so the next invalidation runs beforeLoad with the new user.
  router.update({ context: { user, queryClient } });
  router.invalidate();
});

hydrateRoot(document, <StartClient router={router} />);
```

Order matters: `router.update({ context })` first, then `router.invalidate()`. Invalidating before the update would re-run `beforeLoad` with the stale (null) user.

## \_\_root.tsx — declare context shape

The auth-relevant pieces are the `RouterContext` interface and `createRootRouteWithContext`. The full template (in `assets/templates/src/routes/__root.tsx`) also includes `<Meta />`, `<Scripts />`, and `<ScrollRestoration />` — those are required for SSR hydration; don't omit them in your project's `__root.tsx`.

```tsx
// src/routes/__root.tsx (auth-relevant subset)
import { createRootRouteWithContext } from "@tanstack/react-router";
import type { QueryClient } from "@tanstack/react-query";
import type { User } from "firebase/auth";

interface RouterContext {
  user: User | null;
  queryClient: QueryClient;
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
});
```

## \_authed/route.tsx — the guard

```tsx
// src/routes/_authed/route.tsx
import { createFileRoute, Outlet, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authed")({
  beforeLoad: ({ context, location }) => {
    if (!context.user) {
      throw redirect({
        to: "/auth/sign-in",
        search: { redirect: location.href },
      });
    }
  },
  component: () => <Outlet />,
});
```

`beforeLoad` runs before any child route renders. If the user is null, the redirect throws and the protected route never mounts. No flash.

## Reading the user inside a component

Use `useRouteContext()` from a route. Anywhere inside `_authed/`:

```tsx
import { Route as AuthedRoute } from "~/routes/_authed/route";

function ProfileBadge() {
  const { user } = AuthedRoute.useRouteContext();
  return <span>{user.displayName}</span>;
}
```

`user` is non-null inside `_authed/` because the guard already verified it. No null checks needed in protected components.

For components outside `_authed/` that may or may not have a user (e.g., a header that shows sign-in or profile), read from the root route:

```tsx
import { useRouteContext } from "@tanstack/react-router";

function Header() {
  const { user } = useRouteContext({ from: "__root__" });
  return user ? <ProfileMenu /> : <SignInButton />;
}
```

## Sign-in / sign-out

Plain Firebase Auth calls. No Provider, no service class.

```tsx
// src/features/auth/data.ts
import { signInWithPopup, signOut, GoogleAuthProvider } from "firebase/auth";
import { auth } from "~/lib/firebase";

export const signInWithGoogle = () =>
  signInWithPopup(auth, new GoogleAuthProvider());

export const signOutUser = () => signOut(auth);
```

```tsx
// src/features/auth/components/sign-in-page.tsx
import { signInWithGoogle } from "../data";

export function SignInPage() {
  return (
    <button onClick={() => signInWithGoogle()}>Sign in with Google</button>
  );
}
```

The `onAuthStateChanged` listener in `client.tsx` updates router context automatically — no manual state management.

## Firestore Auth-Owns-Data Pattern

Default Firestore rule: each user can only read/write their own data. See SKILL.md "Firestore Conventions" for the rule snippet. The pattern pairs naturally with the auth setup above — server functions that read/write user data take `context.user.uid` (from the request, after a server-side token verification when needed).

## Sign-Out Cleanup

When the user signs out, the `onAuthStateChanged` listener fires with `null`, `router.invalidate()` runs, and `_authed/route.tsx`'s `beforeLoad` redirects to sign-in. TanStack Query caches stay around — call `queryClient.clear()` after sign-out if your data is user-scoped:

```tsx
import { signOut } from "firebase/auth";
import { auth } from "~/lib/firebase";

export async function fullSignOut(queryClient: QueryClient) {
  await signOut(auth);
  queryClient.clear();
}
```
