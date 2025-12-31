/**
 * Landing page with role selection
 */

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useAuth } from '../App'
import { authApi, childrenApi } from '../lib/api'

export default function Landing() {
  const navigate = useNavigate()
  const { setUser, setChildId } = useAuth()
  const [mode, setMode] = useState<'select' | 'parent' | 'kid'>('select')
  const [email, setEmail] = useState('')
  const [childName, setChildName] = useState('')
  const [childAge, setChildAge] = useState(7)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleParentLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      // Try to login, if not found, register
      let user
      try {
        user = await authApi.login(email)
      } catch {
        user = await authApi.register(email)
      }

      setUser(user)
      navigate('/parent')
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Something went wrong')
    } finally {
      setLoading(false)
    }
  }

  const handleKidStart = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      // MVP: Create a demo parent and child
      const demoEmail = `demo_${Date.now()}@kidsgpt.local`
      const user = await authApi.register(demoEmail, 'Demo Parent')
      const child = await childrenApi.create(user.id, {
        name: childName,
        age: childAge,
      })

      setUser(user)
      setChildId(child.id)
      navigate('/chat')
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Something went wrong')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-lg"
      >
        {mode === 'select' && (
          <div className="text-center">
            {/* Logo/Mascot */}
            <motion.div
              className="mascot-container mb-8"
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', bounce: 0.5 }}
            >
              <div className="w-32 h-32 mx-auto bg-gradient-to-br from-accent-300 to-accent-500 rounded-full flex items-center justify-center shadow-2xl">
                <span className="text-6xl">⚡</span>
              </div>
            </motion.div>

            <h1 className="text-5xl font-display text-primary-600 mb-4">
              KidsGPT
            </h1>
            <p className="text-xl text-gray-600 mb-8">
              Your friendly AI learning buddy!
            </p>

            <div className="space-y-4">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setMode('kid')}
                className="btn-primary w-full text-xl py-4"
              >
                🎮 I'm a Kid - Let's Chat!
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setMode('parent')}
                className="btn-secondary w-full text-xl py-4"
              >
                👨‍👩‍👧 I'm a Parent
              </motion.button>
            </div>

            <p className="mt-8 text-sm text-gray-500">
              Safe, fun, and educational AI for kids 3-13
            </p>
          </div>
        )}

        {mode === 'parent' && (
          <div className="card">
            <button
              onClick={() => setMode('select')}
              className="text-primary-500 mb-4 hover:underline"
            >
              ← Back
            </button>

            <h2 className="text-2xl font-bold text-gray-800 mb-6">
              Parent Login
            </h2>

            <form onSubmit={handleParentLogin} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Email
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="input-fun"
                  placeholder="parent@example.com"
                  required
                />
              </div>

              {error && (
                <p className="text-red-500 text-sm">{error}</p>
              )}

              <button
                type="submit"
                disabled={loading}
                className="btn-primary w-full"
              >
                {loading ? 'Loading...' : 'Continue'}
              </button>
            </form>

            <p className="mt-4 text-sm text-gray-500 text-center">
              New here? We'll create an account for you!
            </p>
          </div>
        )}

        {mode === 'kid' && (
          <div className="card-fun">
            <button
              onClick={() => setMode('select')}
              className="text-primary-600 mb-4 hover:underline"
            >
              ← Back
            </button>

            <div className="text-center mb-6">
              <span className="text-5xl">👋</span>
              <h2 className="text-2xl font-display text-primary-600 mt-2">
                Hi there, friend!
              </h2>
              <p className="text-gray-600">
                Tell me a little about yourself!
              </p>
            </div>

            <form onSubmit={handleKidStart} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  What's your name?
                </label>
                <input
                  type="text"
                  value={childName}
                  onChange={(e) => setChildName(e.target.value)}
                  className="input-fun"
                  placeholder="Your awesome name"
                  required
                  maxLength={50}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  How old are you?
                </label>
                <div className="flex items-center gap-4">
                  <input
                    type="range"
                    min="3"
                    max="13"
                    value={childAge}
                    onChange={(e) => setChildAge(parseInt(e.target.value))}
                    className="flex-1"
                  />
                  <span className="text-3xl font-bold text-primary-600 w-12 text-center">
                    {childAge}
                  </span>
                </div>
              </div>

              {error && (
                <p className="text-red-500 text-sm">{error}</p>
              )}

              <motion.button
                type="submit"
                disabled={loading}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="btn-accent w-full text-xl py-4"
              >
                {loading ? 'Getting ready...' : "🚀 Let's Go!"}
              </motion.button>
            </form>
          </div>
        )}
      </motion.div>
    </div>
  )
}
