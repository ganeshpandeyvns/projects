/**
 * Kids Chat Interface - The main chat experience for children
 */

import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { useQuery, useMutation } from '@tanstack/react-query'
import { useAuth } from '../App'
import { chatApi } from '../lib/api'
import type { Message } from '../lib/api'

// Mascot component
function Mascot({ speaking }: { speaking: boolean }) {
  return (
    <motion.div
      className={`w-16 h-16 bg-gradient-to-br from-accent-300 to-accent-500 rounded-full
                  flex items-center justify-center shadow-lg ${speaking ? 'animate-bounce' : 'animate-float'}`}
    >
      <span className="text-3xl">{speaking ? '💬' : '⚡'}</span>
    </motion.div>
  )
}

// Message bubble component
function ChatBubble({ message, isAssistant }: { message: Message; isAssistant: boolean }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20, scale: 0.9 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      className={`flex ${isAssistant ? 'justify-start' : 'justify-end'} mb-4`}
    >
      {isAssistant && (
        <div className="flex-shrink-0 mr-3">
          <div className="w-10 h-10 bg-gradient-to-br from-secondary-300 to-secondary-500 rounded-full flex items-center justify-center">
            <span className="text-lg">⚡</span>
          </div>
        </div>
      )}
      <div className={isAssistant ? 'chat-bubble-assistant' : 'chat-bubble-child'}>
        <p className="whitespace-pre-wrap">{message.content}</p>
      </div>
    </motion.div>
  )
}

// Thinking indicator
function ThinkingIndicator() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="flex items-center gap-3 mb-4"
    >
      <div className="w-10 h-10 bg-gradient-to-br from-secondary-300 to-secondary-500 rounded-full flex items-center justify-center animate-pulse">
        <span className="text-lg">⚡</span>
      </div>
      <div className="chat-bubble-assistant">
        <div className="flex gap-1">
          <motion.span
            animate={{ opacity: [0.4, 1, 0.4] }}
            transition={{ repeat: Infinity, duration: 1, delay: 0 }}
            className="w-2 h-2 bg-secondary-400 rounded-full"
          />
          <motion.span
            animate={{ opacity: [0.4, 1, 0.4] }}
            transition={{ repeat: Infinity, duration: 1, delay: 0.2 }}
            className="w-2 h-2 bg-secondary-400 rounded-full"
          />
          <motion.span
            animate={{ opacity: [0.4, 1, 0.4] }}
            transition={{ repeat: Infinity, duration: 1, delay: 0.4 }}
            className="w-2 h-2 bg-secondary-400 rounded-full"
          />
        </div>
      </div>
    </motion.div>
  )
}

// Fun emoji suggestions
const EMOJI_SUGGESTIONS = ['😊', '🤔', '🎉', '🌟', '🦄', '🚀', '🌈', '❤️']

export default function KidsChat() {
  const navigate = useNavigate()
  const { childId, logout } = useAuth()
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [conversationId, setConversationId] = useState<number | null>(null)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  // Get today's stats
  const { data: stats, refetch: refetchStats } = useQuery({
    queryKey: ['todayStats', childId],
    queryFn: () => chatApi.getTodayStats(childId!),
    enabled: !!childId,
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  // Send message mutation
  const sendMessage = useMutation({
    mutationFn: (message: string) =>
      chatApi.sendMessage(childId!, message, conversationId || undefined),
    onSuccess: (data) => {
      setMessages(prev => [...prev, data.message, data.response])
      setConversationId(data.conversation_id)
      refetchStats()
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

  const addEmoji = (emoji: string) => {
    setInput(prev => prev + emoji)
    inputRef.current?.focus()
  }

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  const canSendMessage = stats?.can_send_message ?? true
  const messagesRemaining = stats?.messages_remaining ?? 50

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-white shadow-md px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Mascot speaking={sendMessage.isPending} />
          <div>
            <h1 className="font-display text-xl text-primary-600">
              Hi, {stats?.child_name || 'friend'}!
            </h1>
            <p className="text-sm text-gray-500">
              {messagesRemaining} messages left today
            </p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="text-gray-400 hover:text-gray-600 p-2"
        >
          👋 Bye!
        </button>
      </header>

      {/* Messages Area */}
      <main className="flex-1 overflow-y-auto p-4 scrollbar-kid">
        {/* Welcome message */}
        {messages.length === 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-12"
          >
            <div className="w-24 h-24 mx-auto bg-gradient-to-br from-accent-300 to-accent-500 rounded-full flex items-center justify-center shadow-xl mb-6 animate-float">
              <span className="text-5xl">⚡</span>
            </div>
            <h2 className="text-2xl font-display text-primary-600 mb-2">
              I'm Sparky!
            </h2>
            <p className="text-gray-600 max-w-sm mx-auto">
              I'm your AI friend. Ask me anything - about space, dinosaurs,
              math, stories, or whatever you're curious about!
            </p>
            <div className="mt-6 flex flex-wrap justify-center gap-2">
              {['Tell me a fun fact!', 'What are dinosaurs?', 'Help me with math'].map((suggestion) => (
                <button
                  key={suggestion}
                  onClick={() => {
                    setInput(suggestion)
                    inputRef.current?.focus()
                  }}
                  className="px-4 py-2 bg-white rounded-full text-sm text-primary-600
                           shadow hover:shadow-md transition-shadow border border-primary-100"
                >
                  {suggestion}
                </button>
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
            />
          ))}
        </AnimatePresence>

        {/* Thinking indicator */}
        {sendMessage.isPending && <ThinkingIndicator />}

        {/* Error message */}
        {sendMessage.isError && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-center py-4 text-red-500"
          >
            Oops! Something went wrong. Try again?
          </motion.div>
        )}

        <div ref={messagesEndRef} />
      </main>

      {/* Input Area */}
      <footer className="bg-white border-t border-gray-200 p-4">
        {/* Emoji bar */}
        <div className="flex gap-2 mb-3 overflow-x-auto pb-2">
          {EMOJI_SUGGESTIONS.map((emoji) => (
            <button
              key={emoji}
              onClick={() => addEmoji(emoji)}
              className="text-2xl hover:scale-125 transition-transform flex-shrink-0"
            >
              {emoji}
            </button>
          ))}
        </div>

        {/* Input form */}
        <form onSubmit={handleSubmit} className="flex gap-3">
          <input
            ref={inputRef}
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={canSendMessage ? "Ask me anything..." : "Come back tomorrow! 🌙"}
            disabled={!canSendMessage || sendMessage.isPending}
            className="input-fun flex-1"
            maxLength={500}
          />
          <motion.button
            type="submit"
            disabled={!input.trim() || !canSendMessage || sendMessage.isPending}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="btn-primary px-8 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {sendMessage.isPending ? '...' : '🚀'}
          </motion.button>
        </form>

        {/* Message count indicator */}
        {messagesRemaining <= 5 && messagesRemaining > 0 && (
          <p className="text-center text-sm text-amber-600 mt-2">
            Only {messagesRemaining} messages left for today!
          </p>
        )}
      </footer>
    </div>
  )
}
