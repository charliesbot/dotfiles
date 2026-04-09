# Firebase Auth

## Setup

1. Enable Google sign-in in Firebase console (authorized domain: `projectname.charlies.bot`)
2. Contact email: sudo@charlies.bot
3. Ensure `core/firebase.ts` exists (see SKILL.md "Firebase Setup" section) — Auth uses the same wrapper.

## Auth service pattern

In `core/auth/auth.ts`. Injects the `Firebase` wrapper — never calls `getAuth()` directly:

```typescript
import { Injectable, inject, signal, computed } from "@angular/core";
import {
  onAuthStateChanged,
  signInWithPopup,
  signOut,
  GoogleAuthProvider,
  User,
} from "firebase/auth";
import { Firebase } from "../firebase";

@Injectable({ providedIn: "root" })
export class Auth {
  private firebase = inject(Firebase);

  readonly user = signal<User | null>(null);
  readonly ready = signal(false);
  readonly isAuthenticated = computed(() => this.user() !== null);
  readonly uid = computed(() => this.user()?.uid ?? null);

  constructor() {
    // Root singleton — lives for app lifetime, no cleanup needed
    onAuthStateChanged(this.firebase.auth, (user) => {
      this.user.set(user);
      this.ready.set(true);
    });
  }

  async signInWithGoogle(): Promise<void> {
    await signInWithPopup(this.firebase.auth, new GoogleAuthProvider());
  }

  async signOut(): Promise<void> {
    await signOut(this.firebase.auth);
  }
}
```

The `ready` signal tracks whether `onAuthStateChanged` has fired at least once. This prevents guards from redirecting before auth state is known.

## Route guard pattern

In `core/auth/auth-guard.ts`. Waits for auth to settle before making a decision:

```typescript
import { inject } from "@angular/core";
import { toObservable } from "@angular/core/rxjs-interop";
import { CanActivateFn, Router } from "@angular/router";
import { filter, map } from "rxjs";
import { Auth } from "./auth";

export const authGuard: CanActivateFn = () => {
  const auth = inject(Auth);
  const router = inject(Router);

  // Wait until onAuthStateChanged has fired, then decide
  return toObservable(auth.ready).pipe(
    filter((ready) => ready),
    map(() => auth.isAuthenticated() || router.createUrlTree(["/login"])),
  );
};
```

This is one of the rare cases where RxJS is appropriate — Angular's router expects an `Observable<boolean | UrlTree>` for async guards, and we need to wait for the auth state to resolve before allowing or redirecting.
