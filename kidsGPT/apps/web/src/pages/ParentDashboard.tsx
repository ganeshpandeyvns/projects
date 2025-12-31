/**
 * Parent Dashboard - Manage children and view conversations
 */

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuth } from '../App'
import { childrenApi, chatApi } from '../lib/api'
import type { ChildWithStats, Conversation, Message } from '../lib/api'

// Child card component
function ChildCard({
  child,
  onSelect,
  onViewHistory,
}: {
  child: ChildWithStats
  onSelect: () => void
  onViewHistory: () => void
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="card hover:shadow-2xl transition-shadow"
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 bg-gradient-to-br from-primary-400 to-secondary-400 rounded-full flex items-center justify-center text-white text-xl font-bold">
            {child.name.charAt(0).toUpperCase()}
          </div>
          <div>
            <h3 className="font-bold text-lg text-gray-800">{child.name}</h3>
            <p className="text-sm text-gray-500">{child.age} years old</p>
          </div>
        </div>
        <span className={`px-2 py-1 rounded-full text-xs ${
          child.can_send_message
            ? 'bg-green-100 text-green-700'
            : 'bg-amber-100 text-amber-700'
        }`}>
          {child.messages_today}/{child.daily_message_limit} today
        </span>
      </div>

      <div className="grid grid-cols-2 gap-4 mb-4 text-center">
        <div className="bg-primary-50 rounded-xl p-3">
          <p className="text-2xl font-bold text-primary-600">{child.total_conversations}</p>
          <p className="text-xs text-gray-500">Conversations</p>
        </div>
        <div className="bg-secondary-50 rounded-xl p-3">
          <p className="text-2xl font-bold text-secondary-600">{child.total_messages}</p>
          <p className="text-xs text-gray-500">Messages</p>
        </div>
      </div>

      {child.interests && child.interests.length > 0 && (
        <div className="mb-4">
          <p className="text-xs text-gray-500 mb-1">Interests:</p>
          <div className="flex flex-wrap gap-1">
            {child.interests.map((interest) => (
              <span
                key={interest}
                className="px-2 py-1 bg-accent-100 text-accent-700 rounded-full text-xs"
              >
                {interest}
              </span>
            ))}
          </div>
        </div>
      )}

      <div className="flex gap-2">
        <button onClick={onSelect} className="btn-primary flex-1 py-2 text-sm">
          Start Chat
        </button>
        <button onClick={onViewHistory} className="btn-secondary flex-1 py-2 text-sm">
          View History
        </button>
      </div>
    </motion.div>
  )
}

// Add child modal
function AddChildModal({
  onClose,
  onAdd,
}: {
  onClose: () => void
  onAdd: (name: string, age: number, interests: string[]) => void
}) {
  const [name, setName] = useState('')
  const [age, setAge] = useState(7)
  const [interests, setInterests] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const interestList = interests.split(',').map(i => i.trim()).filter(Boolean)
    onAdd(name, age, interestList)
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="card max-w-md w-full"
      >
        <h2 className="text-xl font-bold text-gray-800 mb-4">Add Child Profile</h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="input-fun"
              placeholder="Child's name"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Age: {age}
            </label>
            <input
              type="range"
              min="3"
              max="13"
              value={age}
              onChange={(e) => setAge(parseInt(e.target.value))}
              className="w-full"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Interests (comma separated)
            </label>
            <input
              type="text"
              value={interests}
              onChange={(e) => setInterests(e.target.value)}
              className="input-fun"
              placeholder="dinosaurs, space, art"
            />
          </div>

          <div className="flex gap-2">
            <button type="button" onClick={onClose} className="btn-secondary flex-1">
              Cancel
            </button>
            <button type="submit" className="btn-primary flex-1">
              Add Child
            </button>
          </div>
        </form>
      </motion.div>
    </div>
  )
}

// Conversation history modal
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
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="card max-w-2xl w-full max-h-[80vh] overflow-hidden flex flex-col"
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-800">
            {selectedConv ? 'Conversation' : `${childName}'s Conversations`}
          </h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            ✕
          </button>
        </div>

        {selectedConv ? (
          <>
            <button
              onClick={() => setSelectedConv(null)}
              className="text-primary-500 mb-4 hover:underline text-left"
            >
              ← Back to list
            </button>
            <div className="flex-1 overflow-y-auto space-y-4 scrollbar-kid">
              {convDetail?.messages.map((msg: Message) => (
                <div
                  key={msg.id}
                  className={`p-3 rounded-xl ${
                    msg.role === 'child'
                      ? 'bg-primary-50 ml-8'
                      : 'bg-gray-50 mr-8'
                  }`}
                >
                  <p className="text-xs text-gray-500 mb-1">
                    {msg.role === 'child' ? childName : 'Sparky'}
                  </p>
                  <p className="text-gray-700">{msg.content}</p>
                  {msg.is_flagged && (
                    <span className="text-xs text-red-500">⚠️ Flagged</span>
                  )}
                </div>
              ))}
            </div>
          </>
        ) : (
          <div className="flex-1 overflow-y-auto space-y-2 scrollbar-kid">
            {conversations?.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No conversations yet</p>
            ) : (
              conversations?.map((conv: Conversation) => (
                <button
                  key={conv.id}
                  onClick={() => setSelectedConv(conv.id)}
                  className="w-full text-left p-4 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-gray-800 truncate">
                      {conv.title || 'Untitled conversation'}
                    </p>
                    <span className="text-xs text-gray-500">
                      {conv.message_count} msgs
                    </span>
                  </div>
                  <p className="text-xs text-gray-500">
                    {new Date(conv.started_at).toLocaleDateString()}
                  </p>
                  {conv.is_flagged && (
                    <span className="text-xs text-red-500">⚠️ Contains flagged content</span>
                  )}
                </button>
              ))
            )}
          </div>
        )}
      </motion.div>
    </div>
  )
}

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

  return (
    <div className="min-h-screen p-4 md:p-8">
      {/* Header */}
      <header className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Parent Dashboard</h1>
          <p className="text-gray-500">{user?.email}</p>
        </div>
        <button onClick={handleLogout} className="text-gray-500 hover:text-gray-700">
          Logout
        </button>
      </header>

      {/* Children Grid */}
      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-xl font-semibold text-gray-700">Your Children</h2>
        <button onClick={() => setShowAddChild(true)} className="btn-primary">
          + Add Child
        </button>
      </div>

      {isLoading ? (
        <div className="text-center py-12 text-gray-500">Loading...</div>
      ) : children?.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-500 mb-4">No children added yet</p>
          <button onClick={() => setShowAddChild(true)} className="btn-primary">
            Add Your First Child
          </button>
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {children?.map((child) => (
            <ChildCard
              key={child.id}
              child={child}
              onSelect={() => handleSelectChild(child)}
              onViewHistory={() => setHistoryChild(child)}
            />
          ))}
        </div>
      )}

      {/* Subscription Info */}
      <div className="mt-12 card bg-gradient-to-r from-primary-50 to-secondary-50">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-bold text-gray-800">
              {user?.subscription_tier === 'free' ? 'Free Plan' :
               user?.subscription_tier === 'basic' ? 'Basic Plan' : 'Premium Plan'}
            </h3>
            <p className="text-sm text-gray-500">
              {user?.subscription_tier === 'free'
                ? '1 child, 20 messages/day'
                : user?.subscription_tier === 'basic'
                ? '3 children, 100 messages/day'
                : '5 children, unlimited messages'}
            </p>
          </div>
          {user?.subscription_tier === 'free' && (
            <button className="btn-accent">Upgrade</button>
          )}
        </div>
      </div>

      {/* Modals */}
      {showAddChild && (
        <AddChildModal
          onClose={() => setShowAddChild(false)}
          onAdd={(name, age, interests) => addChild.mutate({ name, age, interests })}
        />
      )}

      {historyChild && (
        <HistoryModal
          childId={historyChild.id}
          parentId={user!.id}
          childName={historyChild.name}
          onClose={() => setHistoryChild(null)}
        />
      )}
    </div>
  )
}
