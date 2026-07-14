import { getApps, initializeApp, applicationDefault, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

// On Firebase App Hosting, Application Default Credentials (ADC) are provided automatically.
// Locally, set GOOGLE_APPLICATION_CREDENTIALS to a service account JSON, OR set the
// FIREBASE_* env vars below for inline credentials.
const credential =
  process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL
    ? cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      })
    : applicationDefault();

const app = getApps()[0] ?? initializeApp({ credential });

export const adminAuth = getAuth(app);
export const db = getFirestore(app);
