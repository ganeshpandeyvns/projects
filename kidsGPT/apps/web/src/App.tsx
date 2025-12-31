import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState, createContext, useContext } from 'react'

// Pages
import KidsChat from './pages/KidsChat'
import ParentDashboard from './pages/ParentDashboard'
import Landing from './pages/Landing'

// Create a query client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
    },
  },
})

// Simple auth context for MVP
interface AuthContextType {
  user: { id: number; email: string; role: string; subscription_tier?: string } | null
  childId: number | null
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
  // MVP: Simple state-based auth (will be replaced with Firebase)
  const [user, setUser] = useState<{ id: number; email: string; role: string; subscription_tier?: string } | null>(null)
  const [childId, setChildId] = useState<number | null>(null)

  const logout = () => {
    setUser(null)
    setChildId(null)
  }

  return (
    <QueryClientProvider client={queryClient}>
      <AuthContext.Provider value={{ user, childId, setUser, setChildId, logout }}>
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

            {/* Catch all */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Router>
      </AuthContext.Provider>
    </QueryClientProvider>
  )
}

export default App
