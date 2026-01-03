/**
 * Firebase configuration and initialization
 */

import { initializeApp, FirebaseApp } from 'firebase/app'
import {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User as FirebaseUser,
  Auth,
  updateProfile,
} from 'firebase/auth'

// Firebase configuration from environment variables
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
}

// Check if Firebase is configured
export const isFirebaseConfigured = (): boolean => {
  return Boolean(
    firebaseConfig.apiKey &&
    firebaseConfig.authDomain &&
    firebaseConfig.projectId
  )
}

// Initialize Firebase only if configured
let app: FirebaseApp | null = null
let auth: Auth | null = null

if (isFirebaseConfigured()) {
  app = initializeApp(firebaseConfig)
  auth = getAuth(app)
}

export { auth, app }
export type { FirebaseUser }

// Auth helper functions
export const firebaseAuth = {
  /**
   * Sign in with email and password
   */
  signIn: async (email: string, password: string) => {
    if (!auth) throw new Error('Firebase not configured')
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    return userCredential.user
  },

  /**
   * Create a new account with email and password
   */
  signUp: async (email: string, password: string, displayName?: string) => {
    if (!auth) throw new Error('Firebase not configured')
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)

    // Update display name if provided
    if (displayName) {
      await updateProfile(userCredential.user, { displayName })
    }

    return userCredential.user
  },

  /**
   * Sign out the current user
   */
  signOut: async () => {
    if (!auth) throw new Error('Firebase not configured')
    await firebaseSignOut(auth)
  },

  /**
   * Get the current Firebase ID token
   */
  getIdToken: async (): Promise<string | null> => {
    if (!auth?.currentUser) return null
    return auth.currentUser.getIdToken()
  },

  /**
   * Force refresh the ID token
   */
  refreshToken: async (): Promise<string | null> => {
    if (!auth?.currentUser) return null
    return auth.currentUser.getIdToken(true)
  },

  /**
   * Get the current user
   */
  getCurrentUser: (): FirebaseUser | null => {
    return auth?.currentUser ?? null
  },

  /**
   * Subscribe to auth state changes
   */
  onAuthStateChanged: (callback: (user: FirebaseUser | null) => void) => {
    if (!auth) {
      // If Firebase not configured, immediately call with null
      callback(null)
      return () => {}
    }
    return onAuthStateChanged(auth, callback)
  },
}
