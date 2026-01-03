/**
 * Landing Page - Premium, professional design with all three portals
 */

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { useMutation } from '@tanstack/react-query'
import { useAuth } from '../App'
import { authApi, adminApi } from '../lib/api'

type PortalType = 'kids' | 'parent' | 'admin' | null

// Animated background
function BackgroundShapes() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <motion.div
        animate={{ y: [0, -20, 0], rotate: [0, 5, 0] }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
        className="absolute top-20 left-10 w-64 h-64 bg-gradient-to-br from-blue-400/20 to-purple-400/20 rounded-full blur-3xl"
      />
      <motion.div
        animate={{ y: [0, 20, 0], rotate: [0, -5, 0] }}
        transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut' }}
        className="absolute top-40 right-20 w-96 h-96 bg-gradient-to-br from-amber-400/20 to-pink-400/20 rounded-full blur-3xl"
      />
      <motion.div
        animate={{ y: [0, 15, 0] }}
        transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
        className="absolute bottom-20 left-1/3 w-80 h-80 bg-gradient-to-br from-green-400/20 to-blue-400/20 rounded-full blur-3xl"
      />
    </div>
  )
}

// Portal Card - Premium Design
function PortalCard({
  title,
  description,
  icon,
  gradient,
  accentColor,
  onClick,
}: {
  title: string
  description: string
  icon: string
  gradient: string
  accentColor: string
  onClick: () => void
}) {
  return (
    <motion.button
      onClick={onClick}
      whileHover={{ scale: 1.03, y: -8 }}
      whileTap={{ scale: 0.97 }}
      className="group relative w-full p-8 rounded-3xl text-left overflow-hidden"
      style={{
        background: 'linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.9) 100%)',
        backdropFilter: 'blur(20px)',
      }}
    >
      {/* Hover glow effect */}
      <div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{
          background: `radial-gradient(circle at 50% 0%, ${accentColor}15 0%, transparent 70%)`,
        }}
      />

      {/* Border gradient */}
      <div className="absolute inset-0 rounded-3xl p-[1px] -z-10"
        style={{
          background: `linear-gradient(180deg, rgba(255,255,255,0.8), rgba(255,255,255,0.4))`,
        }}
      />

      {/* Shadow */}
      <div className="absolute inset-0 -z-20 rounded-3xl shadow-xl group-hover:shadow-2xl transition-shadow duration-300" />

      <div className="relative z-10">
        <motion.div
          whileHover={{ rotate: [0, -5, 5, 0], scale: 1.1 }}
          transition={{ duration: 0.5 }}
          className={`w-18 h-18 rounded-2xl bg-gradient-to-br ${gradient} flex items-center justify-center mb-6 shadow-lg`}
          style={{ width: '72px', height: '72px' }}
        >
          <span className="text-4xl" style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.1))' }}>{icon}</span>
        </motion.div>
        <h3 className="text-2xl font-bold text-gray-800 mb-3 group-hover:text-gray-900 transition-colors">{title}</h3>
        <p className="text-gray-500 leading-relaxed">{description}</p>

        {/* Arrow indicator */}
        <div className="mt-6 flex items-center text-gray-400 group-hover:text-gray-600 transition-colors">
          <span className="text-sm font-medium">Get Started</span>
          <motion.span
            className="ml-2 inline-block"
            animate={{ x: [0, 4, 0] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          >
            →
          </motion.span>
        </div>
      </div>
    </motion.button>
  )
}

// Kids PIN Login Form
function KidsForm({ onBack }: { onBack: () => void }) {
  const navigate = useNavigate()
  const { setChildId } = useAuth()
  const [pin, setPin] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    if (pin.length !== 6) {
      setError('Please enter your 6-digit PIN')
      return
    }

    setLoading(true)
    setError('')

    try {
      const response = await authApi.kidLogin(pin)
      setChildId(response.child_id)
      navigate('/chat')
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Invalid PIN. Please check with your parent.')
    } finally {
      setLoading(false)
    }
  }

  const handlePinChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, '').slice(0, 6)
    setPin(value)
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="w-full max-w-md mx-auto"
    >
      <div className="bg-white rounded-3xl shadow-2xl p-8 border border-gray-100">
        <div className="text-center mb-8">
          <div className="w-20 h-20 mx-auto rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg mb-4">
            <span className="text-4xl">⚡</span>
          </div>
          <h2 className="text-2xl font-bold text-gray-800">Hey there, friend!</h2>
          <p className="text-gray-500 mt-1">Enter your secret PIN to start</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 text-center">
              Your 6-Digit PIN
            </label>
            <input
              type="text"
              inputMode="numeric"
              value={pin}
              onChange={handlePinChange}
              placeholder="• • • • • •"
              maxLength={6}
              className="w-full px-4 py-4 rounded-xl border-2 border-gray-200 focus:border-amber-500 focus:ring-4 focus:ring-amber-100 transition-all outline-none text-3xl text-center font-mono tracking-[0.5em] placeholder:tracking-[0.3em]"
              style={{ letterSpacing: '0.5em' }}
            />
            <p className="text-center text-gray-400 text-sm mt-2">
              Ask your parent for your PIN!
            </p>
          </div>

          {error && <p className="text-red-500 text-sm text-center bg-red-50 py-2 rounded-lg">{error}</p>}

          <button
            type="submit"
            disabled={loading || pin.length !== 6}
            className="w-full py-4 rounded-xl font-bold text-white bg-gradient-to-r from-amber-400 to-orange-500 shadow-lg hover:shadow-xl transition-all disabled:opacity-50 text-lg"
          >
            {loading ? 'Checking...' : "Let's Go! 🚀"}
          </button>
        </form>

        <div className="mt-6 pt-6 border-t border-gray-100">
          <p className="text-center text-gray-400 text-sm mb-2">Don't have a PIN yet?</p>
          <p className="text-center text-gray-500 text-sm">
            Ask your parent to add you in the <strong>Parent Hub</strong>!
          </p>
        </div>

        <button onClick={onBack} className="w-full mt-4 py-3 text-gray-500 hover:text-gray-700 font-medium">
          ← Back
        </button>
      </div>
    </motion.div>
  )
}

// Parent/Admin Login Form
function LoginForm({ portalType, onBack }: { portalType: 'parent' | 'admin'; onBack: () => void }) {
  const navigate = useNavigate()
  const { setUser } = useAuth()
  const [email, setEmail] = useState('')
  const [name, setName] = useState('')
  const [isNewUser, setIsNewUser] = useState(false)
  const [error, setError] = useState('')

  const config = {
    parent: {
      title: 'Parent Portal',
      subtitle: "Manage your children's learning",
      gradient: 'from-blue-500 to-purple-500',
      icon: '👨‍👩‍👧',
    },
    admin: {
      title: 'Admin Portal',
      subtitle: 'System management',
      gradient: 'from-slate-700 to-slate-900',
      icon: '🛡️',
    },
  }[portalType]

  const login = useMutation({
    mutationFn: () => authApi.login(email),
    onSuccess: (user) => {
      if (portalType === 'admin' && user.role !== 'admin') {
        setError('This account does not have admin access. Please use an admin email.')
        return
      }
      setUser(user)
      navigate(portalType === 'admin' ? '/admin' : '/parent')
    },
    onError: () => {
      // User not found - show registration form
      setIsNewUser(true)
      setError('')
    },
  })

  const register = useMutation({
    mutationFn: () => authApi.register(email, name),
    onSuccess: (user) => {
      setUser(user)
      navigate('/parent')
    },
    onError: (err: any) => setError(err.response?.data?.detail || 'Registration failed'),
  })

  const createAdmin = useMutation({
    mutationFn: () => adminApi.createAdmin(email, name || 'Admin'),
    onSuccess: (data) => {
      setUser({ id: data.id, email: data.email, role: 'admin' } as any)
      navigate('/admin')
    },
    onError: (err: any) => {
      // If admin already exists, try to login instead
      if (err.response?.data?.detail?.includes('already exists')) {
        setError('An admin already exists. Please login with the existing admin email.')
        setIsNewUser(false)
      } else {
        setError(err.response?.data?.detail || 'Failed to create admin')
      }
    },
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    if (isNewUser) {
      portalType === 'admin' ? createAdmin.mutate() : register.mutate()
    } else {
      login.mutate()
    }
  }

  const isLoading = login.isPending || register.isPending || createAdmin.isPending

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className="w-full max-w-md mx-auto"
    >
      <div className="bg-white rounded-3xl shadow-2xl p-8 border border-gray-100">
        <div className="text-center mb-8">
          <div className={`w-20 h-20 mx-auto rounded-2xl bg-gradient-to-br ${config.gradient} flex items-center justify-center shadow-lg mb-4`}>
            <span className="text-4xl">{config.icon}</span>
          </div>
          <h2 className="text-2xl font-bold text-gray-800">{config.title}</h2>
          <p className="text-gray-500 mt-1">{config.subtitle}</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              required
              className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 transition-all outline-none"
            />
          </div>

          {isNewUser && (
            <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}>
              <label className="block text-sm font-medium text-gray-700 mb-2">Your Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder={portalType === 'admin' ? 'Admin Name' : 'Your name'}
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 transition-all outline-none"
              />
            </motion.div>
          )}

          {error && <p className="text-red-500 text-sm text-center bg-red-50 py-2 rounded-lg">{error}</p>}

          <button
            type="submit"
            disabled={isLoading}
            className={`w-full py-4 rounded-xl font-bold text-white shadow-lg hover:shadow-xl transition-all disabled:opacity-50 bg-gradient-to-r ${config.gradient}`}
          >
            {isLoading ? 'Please wait...' : isNewUser ? 'Create Account' : 'Continue'}
          </button>
        </form>

        <p className="text-center text-gray-500 mt-6">
          {isNewUser ? (
            <>Already have an account? <button onClick={() => setIsNewUser(false)} className="text-blue-500 font-medium hover:underline">Sign in</button></>
          ) : (
            <>New here? <button onClick={() => setIsNewUser(true)} className="text-blue-500 font-medium hover:underline">Create account</button></>
          )}
        </p>

        <button onClick={onBack} className="w-full mt-4 py-3 text-gray-500 hover:text-gray-700 font-medium">
          ← Back to portal selection
        </button>
      </div>
    </motion.div>
  )
}

// Main Component
export default function Landing() {
  const [selectedPortal, setSelectedPortal] = useState<PortalType>(null)

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-purple-50 relative">
      <BackgroundShapes />

      <div className="relative z-10 min-h-screen flex flex-col items-center justify-center px-4 py-12">
        <AnimatePresence mode="wait">
          {!selectedPortal ? (
            <motion.div
              key="selection"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="w-full max-w-5xl"
            >
              {/* Hero */}
              <div className="text-center mb-12">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring', duration: 0.8 }}
                  className="inline-block mb-6"
                >
                  <div className="w-24 h-24 bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 rounded-3xl flex items-center justify-center shadow-2xl mx-auto">
                    <span className="text-5xl">⚡</span>
                  </div>
                </motion.div>

                <motion.h1
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2 }}
                  className="text-5xl md:text-6xl font-black mb-4"
                  style={{ background: 'linear-gradient(to right, #3b82f6, #8b5cf6, #ec4899)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}
                >
                  KidsGPT
                </motion.h1>

                <motion.p
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 }}
                  className="text-xl text-gray-600 max-w-2xl mx-auto"
                >
                  The safest AI learning companion for children.
                  <br />
                  <span className="text-gray-400">Powered by advanced AI with multi-layer safety.</span>
                </motion.p>
              </div>

              {/* Portal Cards */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="grid md:grid-cols-3 gap-8"
              >
                <PortalCard
                  title="Kids Zone"
                  description="Chat with Sparky, your friendly AI buddy who loves learning and having fun together!"
                  icon="⚡"
                  gradient="from-amber-400 to-orange-500"
                  accentColor="#f59e0b"
                  onClick={() => setSelectedPortal('kids')}
                />
                <PortalCard
                  title="Parent Hub"
                  description="Monitor learning progress, set educational goals, and ensure your children stay safe."
                  icon="👨‍👩‍👧"
                  gradient="from-blue-500 to-purple-500"
                  accentColor="#8b5cf6"
                  onClick={() => setSelectedPortal('parent')}
                />
                <PortalCard
                  title="Admin Panel"
                  description="Complete system management, user oversight, and configuration controls."
                  icon="🛡️"
                  gradient="from-slate-700 to-slate-900"
                  accentColor="#475569"
                  onClick={() => setSelectedPortal('admin')}
                />
              </motion.div>

              {/* Features */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6 }}
                className="mt-20 grid md:grid-cols-4 gap-6"
              >
                {[
                  { icon: '🔒', title: 'COPPA Compliant', desc: 'Enterprise-grade child safety', color: 'from-green-400 to-emerald-500' },
                  { icon: '🧠', title: 'Adaptive AI', desc: 'Age-appropriate responses', color: 'from-blue-400 to-indigo-500' },
                  { icon: '👁️', title: 'Parent Control', desc: 'Full visibility & control', color: 'from-purple-400 to-violet-500' },
                  { icon: '🎯', title: 'Learning Goals', desc: 'Personalized education', color: 'from-amber-400 to-orange-500' },
                ].map((feature, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7 + i * 0.1 }}
                    className="relative p-6 rounded-2xl bg-white/60 backdrop-blur-sm border border-white/50 text-center group hover:bg-white/80 transition-all"
                  >
                    <div className={`w-14 h-14 mx-auto mb-4 rounded-xl bg-gradient-to-br ${feature.color} flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform`}>
                      <span className="text-2xl">{feature.icon}</span>
                    </div>
                    <h4 className="font-bold text-gray-800 mb-1">{feature.title}</h4>
                    <p className="text-sm text-gray-500">{feature.desc}</p>
                  </motion.div>
                ))}
              </motion.div>

              {/* Trust badges */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1 }}
                className="mt-12 flex flex-wrap justify-center items-center gap-8 text-gray-400 text-sm"
              >
                <span className="flex items-center gap-2">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" /></svg>
                  256-bit Encryption
                </span>
                <span className="flex items-center gap-2">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z"/><path fillRule="evenodd" d="M4 5a2 2 0 012-2 3 3 0 003 3h2a3 3 0 003-3 2 2 0 012 2v11a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm9.707 5.707a1 1 0 00-1.414-1.414L9 12.586l-1.293-1.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd"/></svg>
                  COPPA Certified
                </span>
                <span className="flex items-center gap-2">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd"/></svg>
                  SOC 2 Type II
                </span>
              </motion.div>
            </motion.div>
          ) : selectedPortal === 'kids' ? (
            <KidsForm key="kids" onBack={() => setSelectedPortal(null)} />
          ) : (
            <LoginForm key="login" portalType={selectedPortal} onBack={() => setSelectedPortal(null)} />
          )}
        </AnimatePresence>

        {/* Footer with legal links */}
        <motion.footer
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
          className="absolute bottom-6 text-center"
        >
          <div className="flex items-center justify-center gap-4 text-gray-400 text-sm mb-2">
            <button
              onClick={() => window.open('/privacy', '_blank')}
              className="hover:text-gray-600 transition-colors"
            >
              Privacy Policy
            </button>
            <span>•</span>
            <button
              onClick={() => window.open('/terms', '_blank')}
              className="hover:text-gray-600 transition-colors"
            >
              Terms of Service
            </button>
            <span>•</span>
            <button
              onClick={() => window.open('/support', '_blank')}
              className="hover:text-gray-600 transition-colors"
            >
              Support
            </button>
          </div>
          <p className="text-gray-400 text-xs">
            © 2026 KidsGPT • Made with ❤️ for curious kids everywhere
          </p>
        </motion.footer>
      </div>
    </div>
  )
}
