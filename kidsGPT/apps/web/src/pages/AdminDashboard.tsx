/**
 * Admin Dashboard - System management and oversight
 */

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuth } from '../App'
import { adminApi } from '../lib/api'
import type { UserListItem, SystemConfig } from '../lib/api'

// Stats Card Component
function StatCard({
  title,
  value,
  icon,
  color = 'primary',
  trend
}: {
  title: string
  value: number | string
  icon: string
  color?: 'primary' | 'secondary' | 'accent' | 'danger'
  trend?: { value: number; label: string }
}) {
  const colorClasses = {
    primary: 'from-blue-500 to-blue-600',
    secondary: 'from-purple-500 to-purple-600',
    accent: 'from-amber-400 to-amber-500',
    danger: 'from-red-500 to-red-600',
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100"
    >
      <div className="flex items-center justify-between mb-4">
        <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${colorClasses[color]} flex items-center justify-center text-white text-xl shadow-lg`}>
          {icon}
        </div>
        {trend && (
          <span className={`text-sm font-medium ${trend.value >= 0 ? 'text-green-600' : 'text-red-600'}`}>
            {trend.value >= 0 ? '+' : ''}{trend.value}% {trend.label}
          </span>
        )}
      </div>
      <h3 className="text-3xl font-bold text-gray-800 mb-1">{value}</h3>
      <p className="text-gray-500 text-sm">{title}</p>
    </motion.div>
  )
}

// User Row Component
function UserRow({
  user,
  onUpdateTier,
  onToggleActive
}: {
  user: UserListItem
  onUpdateTier: (userId: number, tier: string) => void
  onToggleActive: (userId: number) => void
}) {
  const tierColors: Record<string, string> = {
    free: 'bg-gray-100 text-gray-700',
    basic: 'bg-blue-100 text-blue-700',
    premium: 'bg-purple-100 text-purple-700',
  }

  return (
    <tr className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
      <td className="py-4 px-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-purple-400 flex items-center justify-center text-white font-bold">
            {user.email.charAt(0).toUpperCase()}
          </div>
          <div>
            <p className="font-medium text-gray-800">{user.display_name || 'No Name'}</p>
            <p className="text-sm text-gray-500">{user.email}</p>
          </div>
        </div>
      </td>
      <td className="py-4 px-4">
        <span className={`px-3 py-1 rounded-full text-xs font-medium ${
          user.role === 'admin' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
        }`}>
          {user.role}
        </span>
      </td>
      <td className="py-4 px-4">
        <select
          value={user.subscription_tier.toLowerCase()}
          onChange={(e) => onUpdateTier(user.id, e.target.value)}
          className={`px-3 py-1 rounded-lg text-xs font-medium border-0 cursor-pointer ${tierColors[user.subscription_tier.toLowerCase()] || tierColors.free}`}
        >
          <option value="free">Free</option>
          <option value="basic">Basic</option>
          <option value="premium">Premium</option>
        </select>
      </td>
      <td className="py-4 px-4 text-center">
        <span className="font-medium text-gray-700">{user.children_count}</span>
      </td>
      <td className="py-4 px-4 text-center">
        <span className="font-medium text-gray-700">{user.total_messages}</span>
      </td>
      <td className="py-4 px-4">
        <button
          onClick={() => onToggleActive(user.id)}
          className={`px-3 py-1 rounded-lg text-xs font-medium transition-colors ${
            user.is_active
              ? 'bg-green-100 text-green-700 hover:bg-green-200'
              : 'bg-red-100 text-red-700 hover:bg-red-200'
          }`}
        >
          {user.is_active ? 'Active' : 'Inactive'}
        </button>
      </td>
      <td className="py-4 px-4 text-sm text-gray-500">
        {new Date(user.created_at).toLocaleDateString()}
      </td>
    </tr>
  )
}

// Configuration Panel
function ConfigPanel({
  config,
  onSave
}: {
  config: SystemConfig
  onSave: (config: SystemConfig) => void
}) {
  const [localConfig, setLocalConfig] = useState(config)
  const [hasChanges, setHasChanges] = useState(false)

  const handleChange = (key: keyof SystemConfig, value: any) => {
    setLocalConfig(prev => ({ ...prev, [key]: value }))
    setHasChanges(true)
  }

  return (
    <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
      <h3 className="text-xl font-bold text-gray-800 mb-6">System Configuration</h3>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">AI Provider</label>
          <select
            value={localConfig.ai_provider}
            onChange={(e) => handleChange('ai_provider', e.target.value)}
            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-all"
          >
            <option value="openai">OpenAI (GPT-4)</option>
            <option value="anthropic">Anthropic (Claude)</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Content Filter Level</label>
          <select
            value={localConfig.content_filter_level}
            onChange={(e) => handleChange('content_filter_level', e.target.value)}
            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-all"
          >
            <option value="strict">Strict (Recommended)</option>
            <option value="moderate">Moderate</option>
            <option value="relaxed">Relaxed</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Default Daily Limit</label>
          <input
            type="number"
            value={localConfig.default_daily_limit}
            onChange={(e) => handleChange('default_daily_limit', parseInt(e.target.value))}
            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-all"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Max Children (Free)</label>
          <input
            type="number"
            value={localConfig.max_children_free}
            onChange={(e) => handleChange('max_children_free', parseInt(e.target.value))}
            className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition-all"
          />
        </div>
      </div>

      {hasChanges && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-6 flex justify-end"
        >
          <button
            onClick={() => {
              onSave(localConfig)
              setHasChanges(false)
            }}
            className="px-6 py-3 bg-gradient-to-r from-blue-500 to-purple-500 text-white font-bold rounded-xl shadow-lg hover:shadow-xl transition-all"
          >
            Save Changes
          </button>
        </motion.div>
      )}
    </div>
  )
}

// Main Admin Dashboard
export default function AdminDashboard() {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { user, logout } = useAuth()
  const [activeTab, setActiveTab] = useState<'overview' | 'users' | 'flagged' | 'config'>('overview')

  // Fetch admin stats
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ['adminStats', user?.id],
    queryFn: () => adminApi.getStats(user!.id),
    enabled: !!user,
  })

  // Fetch users
  const { data: users, isLoading: usersLoading } = useQuery({
    queryKey: ['adminUsers', user?.id],
    queryFn: () => adminApi.getUsers(user!.id),
    enabled: !!user && activeTab === 'users',
  })

  // Fetch flagged conversations
  const { data: flagged } = useQuery({
    queryKey: ['flaggedConversations', user?.id],
    queryFn: () => adminApi.getFlaggedConversations(user!.id),
    enabled: !!user && activeTab === 'flagged',
  })

  // Fetch config
  const { data: config } = useQuery({
    queryKey: ['systemConfig', user?.id],
    queryFn: () => adminApi.getConfig(user!.id),
    enabled: !!user && activeTab === 'config',
  })

  // Mutations
  const updateTier = useMutation({
    mutationFn: ({ userId, tier }: { userId: number; tier: string }) =>
      adminApi.updateUserTier(user!.id, userId, tier),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['adminUsers'] }),
  })

  const toggleActive = useMutation({
    mutationFn: (userId: number) => adminApi.toggleUserActive(user!.id, userId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['adminUsers'] }),
  })

  const updateConfig = useMutation({
    mutationFn: (newConfig: SystemConfig) => adminApi.updateConfig(user!.id, newConfig),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['systemConfig'] }),
  })

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  const tabs = [
    { id: 'overview', label: 'Overview', icon: '📊' },
    { id: 'users', label: 'Users', icon: '👥' },
    { id: 'flagged', label: 'Flagged', icon: '⚠️' },
    { id: 'config', label: 'Config', icon: '⚙️' },
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-lg border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-xl flex items-center justify-center text-white font-bold shadow-lg">
                K
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-800">KidsGPT Admin</h1>
                <p className="text-sm text-gray-500">System Management</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-500">{user?.email}</span>
              <button
                onClick={handleLogout}
                className="px-4 py-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Tabs */}
        <div className="flex gap-2 mb-8 bg-white rounded-2xl p-2 shadow-sm">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`flex items-center gap-2 px-6 py-3 rounded-xl font-medium transition-all ${
                activeTab === tab.id
                  ? 'bg-gradient-to-r from-blue-500 to-purple-500 text-white shadow-lg'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              <span>{tab.icon}</span>
              <span>{tab.label}</span>
            </button>
          ))}
        </div>

        {/* Content */}
        <AnimatePresence mode="wait">
          {activeTab === 'overview' && (
            <motion.div
              key="overview"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
            >
              {statsLoading ? (
                <div className="text-center py-12 text-gray-500">Loading stats...</div>
              ) : stats ? (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                  <StatCard
                    title="Total Users"
                    value={stats.total_users}
                    icon="👥"
                    color="primary"
                  />
                  <StatCard
                    title="Total Children"
                    value={stats.total_children}
                    icon="👶"
                    color="secondary"
                  />
                  <StatCard
                    title="Messages Today"
                    value={stats.messages_today}
                    icon="💬"
                    color="accent"
                  />
                  <StatCard
                    title="Flagged"
                    value={stats.flagged_conversations}
                    icon="⚠️"
                    color="danger"
                  />
                  <StatCard
                    title="Total Conversations"
                    value={stats.total_conversations}
                    icon="📝"
                    color="primary"
                  />
                  <StatCard
                    title="Total Messages"
                    value={stats.total_messages}
                    icon="📨"
                    color="secondary"
                  />
                </div>
              ) : (
                <div className="text-center py-12 text-gray-500">
                  Unable to load stats. Make sure you have admin access.
                </div>
              )}
            </motion.div>
          )}

          {activeTab === 'users' && (
            <motion.div
              key="users"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="bg-white rounded-2xl shadow-lg overflow-hidden"
            >
              <div className="p-6 border-b border-gray-100">
                <h3 className="text-xl font-bold text-gray-800">User Management</h3>
                <p className="text-gray-500">Manage user accounts and subscriptions</p>
              </div>
              {usersLoading ? (
                <div className="text-center py-12 text-gray-500">Loading users...</div>
              ) : users && users.length > 0 ? (
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="text-left py-3 px-4 text-sm font-medium text-gray-500">User</th>
                      <th className="text-left py-3 px-4 text-sm font-medium text-gray-500">Role</th>
                      <th className="text-left py-3 px-4 text-sm font-medium text-gray-500">Tier</th>
                      <th className="text-center py-3 px-4 text-sm font-medium text-gray-500">Children</th>
                      <th className="text-center py-3 px-4 text-sm font-medium text-gray-500">Messages</th>
                      <th className="text-left py-3 px-4 text-sm font-medium text-gray-500">Status</th>
                      <th className="text-left py-3 px-4 text-sm font-medium text-gray-500">Joined</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map((user) => (
                      <UserRow
                        key={user.id}
                        user={user}
                        onUpdateTier={(userId, tier) => updateTier.mutate({ userId, tier })}
                        onToggleActive={(userId) => toggleActive.mutate(userId)}
                      />
                    ))}
                  </tbody>
                </table>
              ) : (
                <div className="text-center py-12 text-gray-500">No users found</div>
              )}
            </motion.div>
          )}

          {activeTab === 'flagged' && (
            <motion.div
              key="flagged"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-4"
            >
              <div className="bg-white rounded-2xl shadow-lg p-6">
                <h3 className="text-xl font-bold text-gray-800 mb-2">Flagged Conversations</h3>
                <p className="text-gray-500">Review conversations that triggered safety filters</p>
              </div>
              {flagged && flagged.length > 0 ? (
                flagged.map((conv: any) => (
                  <div key={conv.id} className="bg-white rounded-2xl shadow-lg p-6">
                    <div className="flex items-center justify-between mb-4">
                      <div>
                        <h4 className="font-bold text-gray-800">{conv.title}</h4>
                        <p className="text-sm text-gray-500">
                          {conv.child_name} (Age {conv.child_age}) - {new Date(conv.started_at).toLocaleString()}
                        </p>
                      </div>
                      <span className="px-3 py-1 bg-red-100 text-red-700 rounded-full text-sm font-medium">
                        {conv.flag_reason || 'Flagged'}
                      </span>
                    </div>
                    <div className="space-y-2 max-h-64 overflow-y-auto">
                      {conv.messages.map((msg: any, idx: number) => (
                        <div
                          key={idx}
                          className={`p-3 rounded-xl ${
                            msg.role === 'child' ? 'bg-blue-50 ml-8' : 'bg-gray-50 mr-8'
                          } ${msg.is_flagged ? 'border-2 border-red-300' : ''}`}
                        >
                          <p className="text-xs text-gray-500 mb-1">
                            {msg.role === 'child' ? conv.child_name : 'Sparky'}
                          </p>
                          <p className="text-gray-700">{msg.content}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                ))
              ) : (
                <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
                  <span className="text-4xl mb-4 block">✅</span>
                  <p className="text-gray-500">No flagged conversations. Everything looks safe!</p>
                </div>
              )}
            </motion.div>
          )}

          {activeTab === 'config' && config && (
            <motion.div
              key="config"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
            >
              <ConfigPanel
                config={config}
                onSave={(newConfig) => updateConfig.mutate(newConfig)}
              />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}
