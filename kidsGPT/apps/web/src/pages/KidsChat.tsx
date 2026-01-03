/**
 * Kids Chat Interface - Premium, engaging chat experience for children
 */

import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { useQuery, useMutation } from '@tanstack/react-query'
import { useAuth } from '../App'
import { chatApi } from '../lib/api'
import type { Message } from '../lib/api'

// Sparky mascot component with enhanced animations
function SparkyChatAvatar({ size = 'md', animate = true }: { size?: 'sm' | 'md' | 'lg'; animate?: boolean }) {
  const sizeClasses = {
    sm: 'w-10 h-10 text-lg',
    md: 'w-14 h-14 text-2xl',
    lg: 'w-20 h-20 text-4xl',
  }

  return (
    <motion.div
      animate={animate ? { y: [0, -5, 0] } : {}}
      transition={{ repeat: Infinity, duration: 2, ease: 'easeInOut' }}
      className={`${sizeClasses[size]} rounded-2xl bg-gradient-to-br from-amber-400 via-orange-400 to-rose-400
                  flex items-center justify-center shadow-lg shadow-orange-200`}
    >
      <span>⚡</span>
    </motion.div>
  )
}

// Enhanced message bubble component
function ChatBubble({ message, isAssistant, childName }: { message: Message; isAssistant: boolean; childName?: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ type: 'spring', stiffness: 500, damping: 40 }}
      className={`flex ${isAssistant ? 'justify-start' : 'justify-end'} mb-4`}
    >
      {isAssistant && (
        <div className="flex-shrink-0 mr-3">
          <SparkyChatAvatar size="sm" animate={false} />
        </div>
      )}
      <div className={`relative ${isAssistant ? 'max-w-[80%]' : 'max-w-[80%]'}`}>
        <p className={`text-xs mb-1 ${isAssistant ? 'text-purple-500' : 'text-blue-500'} font-medium`}>
          {isAssistant ? 'Sparky' : childName || 'You'}
        </p>
        <div className={isAssistant ? 'chat-bubble-assistant' : 'chat-bubble-child'}>
          <p className="whitespace-pre-wrap leading-relaxed">{message.content}</p>
        </div>
      </div>
    </motion.div>
  )
}

// Animated thinking indicator
function ThinkingIndicator() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="flex items-center gap-3 mb-4"
    >
      <SparkyChatAvatar size="sm" animate={true} />
      <div className="bg-white rounded-2xl rounded-bl-md px-5 py-3 shadow-md border-2 border-purple-100">
        <div className="flex gap-1.5">
          {[0, 1, 2].map((i) => (
            <motion.div
              key={i}
              animate={{
                y: [-2, 2, -2],
                backgroundColor: ['#d946ef', '#e879f9', '#d946ef'],
              }}
              transition={{
                repeat: Infinity,
                duration: 0.8,
                delay: i * 0.15,
                ease: 'easeInOut',
              }}
              className="w-2.5 h-2.5 rounded-full bg-purple-400"
            />
          ))}
        </div>
      </div>
    </motion.div>
  )
}

// Fun quick suggestions with categories
const QUICK_SUGGESTIONS = [
  { text: 'Tell me a fun fact!', emoji: '💡', color: 'from-amber-400 to-yellow-500' },
  { text: 'Tell me about space!', emoji: '🚀', color: 'from-indigo-400 to-purple-500' },
  { text: 'What are dinosaurs?', emoji: '🦕', color: 'from-green-400 to-emerald-500' },
  { text: 'Help me with math', emoji: '🔢', color: 'from-blue-400 to-cyan-500' },
  { text: 'Tell me a story', emoji: '📖', color: 'from-pink-400 to-rose-500' },
  { text: 'Who are you?', emoji: '⚡', color: 'from-orange-400 to-red-500' },
]

// Emoji bar - expanded
const EMOJI_SUGGESTIONS = ['😊', '🤔', '🎉', '🌟', '🦄', '🚀', '🌈', '❤️', '👍', '🎨', '🦋', '🌸']

// Celebration particles
function CelebrationParticles({ show }: { show: boolean }) {
  if (!show) return null
  return (
    <div className="fixed inset-0 pointer-events-none z-50">
      {[...Array(20)].map((_, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, y: 0, x: Math.random() * window.innerWidth }}
          animate={{
            opacity: [0, 1, 0],
            y: [0, -window.innerHeight],
            rotate: Math.random() * 720,
          }}
          transition={{ duration: 2, delay: Math.random() * 0.5 }}
          className="absolute text-2xl"
          style={{ left: `${Math.random() * 100}%` }}
        >
          {['⭐', '🎉', '✨', '💫', '🌟'][Math.floor(Math.random() * 5)]}
        </motion.div>
      ))}
    </div>
  )
}

export default function KidsChat() {
  const navigate = useNavigate()
  const { childId, logout } = useAuth()
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [conversationId, setConversationId] = useState<number | null>(null)
  const [showCelebration, setShowCelebration] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  // Get today's stats
  const { data: stats, refetch: refetchStats } = useQuery({
    queryKey: ['todayStats', childId],
    queryFn: () => chatApi.getTodayStats(childId!),
    enabled: !!childId,
    refetchInterval: 30000,
  })

  // Send message mutation
  const sendMessage = useMutation({
    mutationFn: (message: string) =>
      chatApi.sendMessage(childId!, message, conversationId || undefined),
    onSuccess: (data) => {
      setMessages((prev) => [...prev, data.message, data.response])
      setConversationId(data.conversation_id)
      refetchStats()
      // Celebrate first message
      if (messages.length === 0) {
        setShowCelebration(true)
        setTimeout(() => setShowCelebration(false), 2500)
      }
    },
  })

  // Scroll to bottom on new messages
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, sendMessage.isPending])

  // Focus input on load
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || sendMessage.isPending) return
    const userMessage = input.trim()
    setInput('')
    sendMessage.mutate(userMessage)
  }

  const handleQuickSuggestion = (text: string) => {
    setInput(text)
    inputRef.current?.focus()
  }

  const addEmoji = (emoji: string) => {
    setInput((prev) => prev + emoji)
    inputRef.current?.focus()
  }

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  const canSendMessage = stats?.can_send_message ?? true
  const messagesRemaining = stats?.messages_remaining ?? 50

  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50">
      {/* Celebration particles */}
      <CelebrationParticles show={showCelebration} />

      {/* Premium Header */}
      <header className="bg-white/80 backdrop-blur-lg shadow-sm px-4 py-3 sticky top-0 z-50 border-b border-white/50">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-4">
            <SparkyChatAvatar size="md" />
            <div>
              <h1 className="font-display text-xl bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent">
                Hi, {stats?.child_name || 'friend'}!
              </h1>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-400 animate-pulse" />
                <p className="text-sm text-gray-500">
                  {messagesRemaining} messages left today
                </p>
              </div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="flex items-center gap-2 text-gray-400 hover:text-gray-600 px-4 py-2 rounded-full hover:bg-gray-100 transition-all"
          >
            <span>Bye!</span>
            <span className="text-xl">👋</span>
          </button>
        </div>
      </header>

      {/* Messages Area */}
      <main className="flex-1 overflow-y-auto px-4 py-6 scrollbar-kid">
        <div className="max-w-3xl mx-auto">
          {/* Welcome State */}
          {messages.length === 0 && (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center py-8"
            >
              <motion.div
                animate={{ y: [0, -10, 0], rotate: [0, 5, -5, 0] }}
                transition={{ repeat: Infinity, duration: 4, ease: 'easeInOut' }}
                className="inline-block mb-6"
              >
                <div className="w-28 h-28 mx-auto rounded-3xl bg-gradient-to-br from-amber-400 via-orange-400 to-rose-400 flex items-center justify-center shadow-2xl shadow-orange-200/50">
                  <span className="text-6xl">⚡</span>
                </div>
              </motion.div>

              <h2 className="text-3xl font-display bg-gradient-to-r from-amber-500 via-orange-500 to-rose-500 bg-clip-text text-transparent mb-3">
                I'm Sparky!
              </h2>
              <p className="text-gray-600 max-w-md mx-auto mb-8 leading-relaxed">
                I'm your AI best friend. Ask me anything - about space, dinosaurs,
                math, stories, or whatever makes you curious!
              </p>

              {/* Quick Suggestions - Premium Grid */}
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4 max-w-2xl mx-auto">
                {QUICK_SUGGESTIONS.map((suggestion, i) => (
                  <motion.button
                    key={suggestion.text}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.2 + i * 0.1 }}
                    whileHover={{ scale: 1.05, y: -4 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => handleQuickSuggestion(suggestion.text)}
                    className="group relative flex flex-col items-center gap-2 p-5 bg-white rounded-2xl shadow-lg hover:shadow-xl
                             border border-gray-100 transition-all overflow-hidden"
                  >
                    <div className={`absolute inset-0 bg-gradient-to-br ${suggestion.color} opacity-0 group-hover:opacity-10 transition-opacity`} />
                    <motion.span
                      className="text-3xl"
                      whileHover={{ rotate: [0, -10, 10, 0], scale: 1.2 }}
                      transition={{ duration: 0.5 }}
                    >
                      {suggestion.emoji}
                    </motion.span>
                    <span className="text-sm text-gray-700 font-medium text-center">{suggestion.text}</span>
                  </motion.button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Chat messages */}
          <AnimatePresence>
            {messages.map((message) => (
              <ChatBubble
                key={message.id}
                message={message}
                isAssistant={message.role === 'assistant'}
                childName={stats?.child_name}
              />
            ))}
          </AnimatePresence>

          {/* Thinking indicator */}
          <AnimatePresence>{sendMessage.isPending && <ThinkingIndicator />}</AnimatePresence>

          {/* Error message */}
          {sendMessage.isError && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center py-4"
            >
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-red-50 text-red-600 rounded-full">
                <span>😅</span>
                <span>Oops! Something went wrong. Try again?</span>
              </div>
            </motion.div>
          )}

          <div ref={messagesEndRef} />
        </div>
      </main>

      {/* Input Area */}
      <footer className="bg-white/90 backdrop-blur-lg border-t border-gray-100 px-4 py-4">
        <div className="max-w-3xl mx-auto">
          {/* Emoji bar */}
          <div className="flex gap-2 mb-3 overflow-x-auto pb-2 scrollbar-kid">
            {EMOJI_SUGGESTIONS.map((emoji) => (
              <motion.button
                key={emoji}
                whileHover={{ scale: 1.3 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => addEmoji(emoji)}
                className="text-2xl flex-shrink-0 hover:bg-gray-100 p-1 rounded-lg transition-colors"
              >
                {emoji}
              </motion.button>
            ))}
          </div>

          {/* Input form */}
          <form onSubmit={handleSubmit} className="flex gap-3">
            <div className="flex-1 relative">
              <input
                ref={inputRef}
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder={canSendMessage ? 'Ask me anything...' : 'Come back tomorrow! 🌙'}
                disabled={!canSendMessage || sendMessage.isPending}
                className="input-fun pr-16"
                maxLength={500}
              />
              <span className="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-gray-400">
                {input.length}/500
              </span>
            </div>
            <motion.button
              type="submit"
              disabled={!input.trim() || !canSendMessage || sendMessage.isPending}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="btn-primary px-8 py-3 text-xl disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
            >
              {sendMessage.isPending ? (
                <motion.span
                  animate={{ rotate: 360 }}
                  transition={{ repeat: Infinity, duration: 1, ease: 'linear' }}
                >
                  ⏳
                </motion.span>
              ) : (
                '🚀'
              )}
            </motion.button>
          </form>

          {/* Message count warning */}
          {messagesRemaining <= 5 && messagesRemaining > 0 && (
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center text-sm text-amber-600 mt-3 bg-amber-50 py-2 rounded-full"
            >
              ⚠️ Only {messagesRemaining} messages left for today!
            </motion.p>
          )}

          {!canSendMessage && (
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-center text-sm text-purple-600 mt-3 bg-purple-50 py-2 rounded-full"
            >
              🌙 You've used all your messages! Come back tomorrow for more adventures!
            </motion.p>
          )}
        </div>
      </footer>
    </div>
  )
}
