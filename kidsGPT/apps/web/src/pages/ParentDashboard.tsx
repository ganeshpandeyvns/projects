/**
 * Parent Dashboard - Premium, professional management interface
 */

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuth } from '../App'
import { childrenApi, chatApi } from '../lib/api'
import type { ChildWithStats, Conversation, Message } from '../lib/api'

// Animated stat card with premium styling
function StatCard({ value, label, icon, gradient }: { value: number; label: string; icon: string; gradient: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ scale: 1.02, y: -2 }}
      className={`p-4 rounded-2xl bg-gradient-to-br ${gradient} text-white relative overflow-hidden`}
    >
      <div className="absolute inset-0 bg-gradient-to-t from-black/10 to-transparent" />
      <div className="relative flex items-center gap-3">
        <span className="text-2xl drop-shadow-sm">{icon}</span>
        <div>
          <p className="text-2xl font-bold tracking-tight">{value}</p>
          <p className="text-sm opacity-90 font-medium">{label}</p>
        </div>
      </div>
    </motion.div>
  )
}

// Premium child card component
function ChildCard({
  child,
  onSelect,
  onViewHistory,
}: {
  child: ChildWithStats
  onSelect: () => void
  onViewHistory: () => void
}) {
  const progressPercent = Math.min((child.messages_today / child.daily_message_limit) * 100, 100)

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ y: -4 }}
      className="bg-white rounded-3xl p-6 shadow-lg hover:shadow-2xl transition-all border border-gray-100"
    >
      <div className="flex items-start justify-between mb-6">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 rounded-2xl flex items-center justify-center text-white text-2xl font-bold shadow-lg">
            {child.name.charAt(0).toUpperCase()}
          </div>
          <div>
            <h3 className="font-bold text-xl text-gray-800">{child.name}</h3>
            <p className="text-gray-500">{child.age} years old</p>
          </div>
        </div>
        <span
          className={`px-3 py-1.5 rounded-full text-xs font-semibold ${
            child.can_send_message
              ? 'bg-green-100 text-green-700'
              : 'bg-amber-100 text-amber-700'
          }`}
        >
          {child.can_send_message ? 'Active' : 'Limit Reached'}
        </span>
      </div>

      {/* Progress bar */}
      <div className="mb-6">
        <div className="flex justify-between text-sm text-gray-500 mb-2">
          <span>Daily Progress</span>
          <span>{child.messages_today} / {child.daily_message_limit} messages</span>
        </div>
        <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progressPercent}%` }}
            transition={{ duration: 0.8, ease: 'easeOut' }}
            className={`h-full rounded-full ${
              progressPercent >= 100
                ? 'bg-gradient-to-r from-amber-400 to-red-400'
                : 'bg-gradient-to-r from-blue-500 to-purple-500'
            }`}
          />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 mb-6">
        <StatCard
          value={child.total_conversations}
          label="Chats"
          icon="💬"
          gradient="from-blue-500 to-blue-600"
        />
        <StatCard
          value={child.total_messages}
          label="Messages"
          icon="📨"
          gradient="from-purple-500 to-purple-600"
        />
      </div>

      {/* Interests */}
      {child.interests && child.interests.length > 0 && (
        <div className="mb-6">
          <p className="text-xs text-gray-500 mb-2 font-medium uppercase tracking-wider">Interests</p>
          <div className="flex flex-wrap gap-2">
            {child.interests.map((interest) => (
              <span
                key={interest}
                className="px-3 py-1 bg-gradient-to-r from-amber-50 to-orange-50 text-amber-700 rounded-full text-sm font-medium border border-amber-100"
              >
                {interest}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Actions */}
      <div className="flex gap-3">
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={onSelect}
          className="btn-primary flex-1 py-3 text-sm"
        >
          🚀 Start Chat
        </motion.button>
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={onViewHistory}
          className="btn-secondary flex-1 py-3 text-sm"
        >
          📜 History
        </motion.button>
      </div>
    </motion.div>
  )
}

// Premium Add Child Modal
function AddChildModal({
  onClose,
  onAdd,
  isLoading,
}: {
  onClose: () => void
  onAdd: (name: string, age: number, interests: string[]) => void
  isLoading?: boolean
}) {
  const [name, setName] = useState('')
  const [age, setAge] = useState(7)
  const [interests, setInterests] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const interestList = interests.split(',').map((i) => i.trim()).filter(Boolean)
    onAdd(name, age, interestList)
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        onClick={(e) => e.stopPropagation()}
        className="bg-white rounded-3xl shadow-2xl max-w-md w-full p-8"
      >
        <div className="text-center mb-6">
          <div className="w-16 h-16 mx-auto bg-gradient-to-br from-blue-500 to-purple-500 rounded-2xl flex items-center justify-center text-3xl shadow-lg mb-4">
            👶
          </div>
          <h2 className="text-2xl font-bold text-gray-800">Add Child Profile</h2>
          <p className="text-gray-500">Create a new profile for your child</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 transition-all outline-none"
              placeholder="Child's name"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Age: <span className="text-2xl font-bold text-blue-600">{age}</span>
            </label>
            <input
              type="range"
              min="3"
              max="13"
              value={age}
              onChange={(e) => setAge(parseInt(e.target.value))}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-400 mt-1">
              <span>3 years</span>
              <span>13 years</span>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Interests <span className="text-gray-400">(comma separated)</span>
            </label>
            <input
              type="text"
              value={interests}
              onChange={(e) => setInterests(e.target.value)}
              className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 transition-all outline-none"
              placeholder="dinosaurs, space, art"
            />
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-3 rounded-xl font-bold text-gray-600 bg-gray-100 hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
            <motion.button
              type="submit"
              disabled={isLoading}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="btn-primary flex-1 py-3 disabled:opacity-50"
            >
              {isLoading ? 'Creating...' : 'Add Child'}
            </motion.button>
          </div>
        </form>
      </motion.div>
    </motion.div>
  )
}

// Conversation History Modal
function HistoryModal({
  childId,
  parentId,
  childName,
  onClose,
}: {
  childId: number
  parentId: number
  childName: string
  onClose: () => void
}) {
  const [selectedConv, setSelectedConv] = useState<number | null>(null)

  const { data: conversations } = useQuery({
    queryKey: ['conversations', childId],
    queryFn: () => chatApi.getConversations(childId, parentId),
  })

  const { data: convDetail } = useQuery({
    queryKey: ['conversation', selectedConv],
    queryFn: () => chatApi.getConversation(selectedConv!, parentId),
    enabled: !!selectedConv,
  })

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        onClick={(e) => e.stopPropagation()}
        className="bg-white rounded-3xl shadow-2xl max-w-2xl w-full max-h-[80vh] overflow-hidden flex flex-col"
      >
        {/* Header */}
        <div className="p-6 border-b border-gray-100 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold text-gray-800">
              {selectedConv ? 'Conversation Details' : `${childName}'s Conversations`}
            </h2>
            <p className="text-gray-500 text-sm">Review chat history and learning moments</p>
          </div>
          <button
            onClick={onClose}
            className="w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-500 transition-colors"
          >
            ✕
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6 scrollbar-kid">
          {selectedConv ? (
            <>
              <button
                onClick={() => setSelectedConv(null)}
                className="flex items-center gap-2 text-blue-500 hover:text-blue-700 mb-4 font-medium"
              >
                ← Back to list
              </button>
              <div className="space-y-4">
                {convDetail?.messages.map((msg: Message) => (
                  <div
                    key={msg.id}
                    className={`p-4 rounded-2xl ${
                      msg.role === 'child'
                        ? 'bg-gradient-to-r from-blue-50 to-blue-100 ml-8'
                        : 'bg-gray-50 mr-8'
                    }`}
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-lg">{msg.role === 'child' ? '👤' : '⚡'}</span>
                      <p className="text-sm font-medium text-gray-600">
                        {msg.role === 'child' ? childName : 'Sparky'}
                      </p>
                      {msg.is_flagged && (
                        <span className="px-2 py-0.5 bg-red-100 text-red-600 rounded-full text-xs font-medium">
                          Flagged
                        </span>
                      )}
                    </div>
                    <p className="text-gray-700 leading-relaxed">{msg.content}</p>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <div className="space-y-3">
              {conversations?.length === 0 ? (
                <div className="text-center py-12">
                  <span className="text-4xl mb-4 block">📭</span>
                  <p className="text-gray-500">No conversations yet</p>
                  <p className="text-gray-400 text-sm">Start chatting to see history here</p>
                </div>
              ) : (
                conversations?.map((conv: Conversation) => (
                  <motion.button
                    key={conv.id}
                    whileHover={{ scale: 1.01 }}
                    onClick={() => setSelectedConv(conv.id)}
                    className="w-full text-left p-4 bg-gray-50 hover:bg-gray-100 rounded-2xl transition-all border border-transparent hover:border-gray-200"
                  >
                    <div className="flex items-center justify-between mb-2">
                      <p className="font-medium text-gray-800 truncate flex items-center gap-2">
                        <span>💬</span>
                        {conv.title || 'Untitled conversation'}
                      </p>
                      <span className="px-3 py-1 bg-blue-100 text-blue-600 rounded-full text-xs font-medium">
                        {conv.message_count} msgs
                      </span>
                    </div>
                    <p className="text-sm text-gray-500">
                      {new Date(conv.started_at).toLocaleDateString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                      })}
                    </p>
                    {conv.is_flagged && (
                      <span className="inline-flex items-center gap-1 text-xs text-red-500 mt-2">
                        ⚠️ Contains flagged content
                      </span>
                    )}
                  </motion.button>
                ))
              )}
            </div>
          )}
        </div>
      </motion.div>
    </motion.div>
  )
}

// Main Dashboard Component
export default function ParentDashboard() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { user, setChildId, logout } = useAuth()
  const [showAddChild, setShowAddChild] = useState(false)
  const [historyChild, setHistoryChild] = useState<ChildWithStats | null>(null)

  const { data: children, isLoading } = useQuery({
    queryKey: ['children', user?.id],
    queryFn: () => childrenApi.list(user!.id),
    enabled: !!user,
  })

  const addChild = useMutation({
    mutationFn: ({ name, age, interests }: { name: string; age: number; interests: string[] }) =>
      childrenApi.create(user!.id, { name, age, interests }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['children'] })
      setShowAddChild(false)
    },
  })

  const handleSelectChild = (child: ChildWithStats) => {
    setChildId(child.id)
    navigate('/chat')
  }

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  const tierInfo = {
    free: { name: 'Free', color: 'from-gray-500 to-gray-600', limits: '1 child, 20 msgs/day' },
    basic: { name: 'Basic', color: 'from-blue-500 to-blue-600', limits: '3 children, 100 msgs/day' },
    premium: { name: 'Premium', color: 'from-purple-500 to-purple-600', limits: '5 children, unlimited' },
  }

  const currentTier = tierInfo[user?.subscription_tier as keyof typeof tierInfo] || tierInfo.free

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-purple-50">
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-lg border-b border-gray-100 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-600 to-purple-600 rounded-2xl flex items-center justify-center text-white font-bold text-xl shadow-lg">
                K
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-800">Parent Dashboard</h1>
                <p className="text-sm text-gray-500">{user?.email}</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className={`px-4 py-2 rounded-full bg-gradient-to-r ${currentTier.color} text-white text-sm font-medium shadow-md`}>
                {currentTier.name} Plan
              </div>
              <button
                onClick={handleLogout}
                className="px-4 py-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-xl transition-all"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Section Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Your Children</h2>
            <p className="text-gray-500">Manage profiles and view activity</p>
          </div>
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => setShowAddChild(true)}
            className="btn-primary flex items-center gap-2"
          >
            <span className="text-xl">+</span>
            Add Child
          </motion.button>
        </div>

        {/* Children Grid */}
        {isLoading ? (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white rounded-3xl p-6 shadow-lg animate-pulse">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-16 h-16 bg-gray-200 rounded-2xl" />
                  <div>
                    <div className="h-5 w-24 bg-gray-200 rounded mb-2" />
                    <div className="h-4 w-16 bg-gray-100 rounded" />
                  </div>
                </div>
                <div className="h-3 bg-gray-200 rounded-full mb-6" />
                <div className="grid grid-cols-2 gap-4 mb-6">
                  <div className="h-16 bg-gray-100 rounded-2xl" />
                  <div className="h-16 bg-gray-100 rounded-2xl" />
                </div>
                <div className="flex gap-3">
                  <div className="h-12 flex-1 bg-gray-200 rounded-full" />
                  <div className="h-12 flex-1 bg-gray-200 rounded-full" />
                </div>
              </div>
            ))}
          </div>
        ) : children?.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-16 bg-white rounded-3xl shadow-lg"
          >
            <div className="w-24 h-24 mx-auto bg-gradient-to-br from-blue-100 to-purple-100 rounded-3xl flex items-center justify-center text-5xl mb-6">
              👶
            </div>
            <h3 className="text-xl font-bold text-gray-800 mb-2">No children added yet</h3>
            <p className="text-gray-500 mb-6">Add your first child to get started with KidsGPT</p>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setShowAddChild(true)}
              className="btn-primary"
            >
              Add Your First Child
            </motion.button>
          </motion.div>
        ) : (
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {children?.map((child, index) => (
              <motion.div
                key={child.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <ChildCard
                  child={child}
                  onSelect={() => handleSelectChild(child)}
                  onViewHistory={() => setHistoryChild(child)}
                />
              </motion.div>
            ))}
          </div>
        )}

        {/* Subscription Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-12 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 rounded-3xl p-8 text-white shadow-2xl"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-2xl font-bold mb-2">{currentTier.name} Plan</h3>
              <p className="opacity-80">{currentTier.limits}</p>
            </div>
            {user?.subscription_tier === 'free' && (
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="px-8 py-3 bg-white text-purple-600 font-bold rounded-full shadow-lg hover:shadow-xl transition-all"
              >
                Upgrade Now
              </motion.button>
            )}
          </div>
        </motion.div>
      </main>

      {/* Modals */}
      <AnimatePresence>
        {showAddChild && (
          <AddChildModal
            onClose={() => setShowAddChild(false)}
            onAdd={(name, age, interests) => addChild.mutate({ name, age, interests })}
            isLoading={addChild.isPending}
          />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {historyChild && (
          <HistoryModal
            childId={historyChild.id}
            parentId={user!.id}
            childName={historyChild.name}
            onClose={() => setHistoryChild(null)}
          />
        )}
      </AnimatePresence>
    </div>
  )
}
