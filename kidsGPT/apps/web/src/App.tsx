import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState, useEffect, createContext, useContext } from 'react'

// Pages
import KidsChat from './pages/KidsChat'
import ParentDashboard from './pages/ParentDashboard'
import AdminDashboard from './pages/AdminDashboard'
import Landing from './pages/Landing'

// Firebase
import { firebaseAuth, isFirebaseConfigured, FirebaseUser } from './lib/firebase'
import { authApi } from './lib/api'

// Create a query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
    },
  },
})

// Auth context with Firebase support
interface AuthContextType {
  user: { id: number; email: string; role: string; subscription_tier?: string } | null
  firebaseUser: FirebaseUser | null
  childId: number | null
  isLoading: boolean
  isFirebaseEnabled: boolean
  setUser: (user: any) => void
  setChildId: (id: number | null) => void
  logout: () => void
}

const AuthContext = createContext<AuthContextType | null>(null)

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}

function App() {
  const [user, setUser] = useState<{ id: number; email: string; role: string; subscription_tier?: string } | null>(null)
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null)
  const [childId, setChildId] = useState<number | null>(null)
  const [isLoading, setIsLoading] = useState(isFirebaseConfigured()) // Only loading if Firebase is configured
  const isFirebaseEnabled = isFirebaseConfigured()

  // Listen for Firebase auth state changes
  useEffect(() => {
    if (!isFirebaseEnabled) {
      setIsLoading(false)
      return
    }

    const unsubscribe = firebaseAuth.onAuthStateChanged(async (fbUser) => {
      setFirebaseUser(fbUser)

      if (fbUser) {
        try {
          // Get ID token and sync with backend
          const idToken = await fbUser.getIdToken()
          const backendUser = await authApi.firebaseLogin(idToken, fbUser.displayName || undefined)
          setUser(backendUser)
        } catch (error) {
          console.error('Failed to sync with backend:', error)
          // If backend sync fails, still sign out of Firebase
          await firebaseAuth.signOut()
          setUser(null)
        }
      } else {
        setUser(null)
      }

      setIsLoading(false)
    })

    return () => unsubscribe()
  }, [isFirebaseEnabled])

  const logout = async () => {
    if (isFirebaseEnabled) {
      await firebaseAuth.signOut()
    }
    setUser(null)
    setFirebaseUser(null)
    setChildId(null)
  }

  // Show loading screen while checking Firebase auth state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-purple-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-500">Loading...</p>
        </div>
      </div>
    )
  }

  return (
    <QueryClientProvider client={queryClient}>
      <AuthContext.Provider value={{
        user,
        firebaseUser,
        childId,
        isLoading,
        isFirebaseEnabled,
        setUser,
        setChildId,
        logout
      }}>
        <Router>
          <Routes>
            {/* Landing / Login */}
            <Route path="/" element={<Landing />} />

            {/* Kids Chat Interface */}
            <Route
              path="/chat"
              element={
                childId ? <KidsChat /> : <Navigate to="/" replace />
              }
            />

            {/* Parent Dashboard */}
            <Route
              path="/parent/*"
              element={
                user ? <ParentDashboard /> : <Navigate to="/" replace />
              }
            />

            {/* Admin Dashboard */}
            <Route
              path="/admin/*"
              element={
                user?.role === 'admin' ? <AdminDashboard /> : <Navigate to="/" replace />
              }
            />

            {/* Catch all */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Router>
      </AuthContext.Provider>
    </QueryClientProvider>
  )
}

export default App
