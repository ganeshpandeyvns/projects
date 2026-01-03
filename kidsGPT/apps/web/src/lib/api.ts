/**
 * API client for KidsGPT backend
 */

import axios from 'axios'
import { firebaseAuth, isFirebaseConfigured } from './firebase'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add auth interceptor to attach Firebase ID token to requests
api.interceptors.request.use(async (config) => {
  // Only add token if Firebase is configured
  if (isFirebaseConfigured()) {
    try {
      const token = await firebaseAuth.getIdToken()
      if (token) {
        config.headers.Authorization = `Bearer ${token}`
      }
    } catch (error) {
      console.warn('Failed to get Firebase token:', error)
    }
  }
  return config
})

// Add response interceptor to handle token expiry
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config

    // If we get a 401 and haven't retried yet, try to refresh the token
    if (error.response?.status === 401 && !originalRequest._retry && isFirebaseConfigured()) {
      originalRequest._retry = true

      try {
        const newToken = await firebaseAuth.refreshToken()
        if (newToken) {
          originalRequest.headers.Authorization = `Bearer ${newToken}`
          return api(originalRequest)
        }
      } catch (refreshError) {
        console.warn('Token refresh failed:', refreshError)
      }
    }

    return Promise.reject(error)
  }
)

// Types
export interface User {
  id: number
  email: string
  display_name: string | null
  role: 'parent' | 'admin'
  subscription_tier: 'free' | 'basic' | 'premium'
  is_active: boolean
  created_at: string
}

export interface Child {
  id: number
  parent_id: number
  name: string
  age: number
  login_pin: string  // 6-digit PIN for kid login
  avatar_id: string | null
  interests: string[] | null
  learning_goals: string[] | null
  daily_message_limit: number
  messages_today: number
  last_message_date: string | null
  is_active: boolean
  created_at: string
}

export interface KidLoginResponse {
  child_id: number
  child_name: string
  age: number
  avatar_id: string | null
  daily_limit: number
  messages_remaining: number
  can_send_message: boolean
  parent_name: string | null
}

export interface ChildWithStats extends Child {
  total_conversations: number
  total_messages: number
  can_send_message: boolean
}

export interface Message {
  id: number
  conversation_id: number
  role: 'child' | 'assistant'
  content: string
  is_flagged: boolean
  created_at: string
}

export interface Conversation {
  id: number
  child_id: number
  title: string | null
  started_at: string
  ended_at: string | null
  is_flagged: boolean
  message_count: number
}

export interface ChatResponse {
  conversation_id: number
  message: Message
  response: Message
  messages_remaining_today: number
  safety_note: string | null
}

export interface TodayStats {
  child_id: number
  child_name: string
  messages_sent_today: number
  daily_limit: number
  messages_remaining: number
  can_send_message: boolean
}

// Admin Types
export interface AdminStats {
  total_users: number
  total_children: number
  total_conversations: number
  total_messages: number
  messages_today: number
  active_users_today: number
  flagged_conversations: number
}

export interface UserListItem {
  id: number
  email: string
  display_name: string | null
  role: string
  subscription_tier: string
  is_active: boolean
  created_at: string
  children_count: number
  total_messages: number
}

export interface SystemConfig {
  ai_provider: string
  default_daily_limit: number
  max_children_free: number
  max_children_basic: number
  max_children_premium: number
  content_filter_level: string
}

// Auth API
export const authApi = {
  /**
   * Firebase authentication - sends ID token to backend
   * This is the primary auth method when Firebase is configured
   */
  firebaseLogin: async (idToken: string, displayName?: string) => {
    const { data } = await api.post<User>('/auth/firebase-login', {
      id_token: idToken,
      display_name: displayName,
    })
    return data
  },

  /**
   * Legacy register - for MVP without Firebase
   * @deprecated Use Firebase auth instead
   */
  register: async (email: string, displayName?: string) => {
    const { data } = await api.post<User>('/auth/register', {
      email,
      display_name: displayName,
    })
    return data
  },

  /**
   * Legacy login - for MVP without Firebase
   * @deprecated Use Firebase auth instead
   */
  login: async (email: string) => {
    const { data } = await api.post<User>(`/auth/login?email=${encodeURIComponent(email)}`)
    return data
  },

  /**
   * Get current user profile (requires Firebase auth token)
   */
  getMe: async () => {
    const { data } = await api.get<User>('/auth/me')
    return data
  },

  /**
   * Legacy getMe - for MVP without Firebase
   * @deprecated Use getMe() with Firebase token instead
   */
  getMeLegacy: async (userId: number) => {
    const { data } = await api.get<User>(`/auth/me-legacy?user_id=${userId}`)
    return data
  },

  /**
   * Kid login with PIN (no Firebase required)
   */
  kidLogin: async (pin: string) => {
    const { data } = await api.post<KidLoginResponse>('/auth/kid-login', { pin })
    return data
  },
}

// Children API
export const childrenApi = {
  create: async (parentId: number, child: { name: string; age: number; interests?: string[] }) => {
    const { data } = await api.post<Child>(`/children?parent_id=${parentId}`, child)
    return data
  },

  list: async (parentId: number) => {
    const { data } = await api.get<ChildWithStats[]>(`/children?parent_id=${parentId}`)
    return data
  },

  get: async (childId: number, parentId: number) => {
    const { data } = await api.get<ChildWithStats>(`/children/${childId}?parent_id=${parentId}`)
    return data
  },

  update: async (childId: number, parentId: number, updates: Partial<Child>) => {
    const { data } = await api.patch<Child>(`/children/${childId}?parent_id=${parentId}`, updates)
    return data
  },

  delete: async (childId: number, parentId: number) => {
    await api.delete(`/children/${childId}?parent_id=${parentId}`)
  },

  regeneratePin: async (childId: number, parentId: number) => {
    const { data } = await api.post<Child>(`/children/${childId}/regenerate-pin?parent_id=${parentId}`)
    return data
  },
}

// Chat API
export const chatApi = {
  sendMessage: async (childId: number, message: string, conversationId?: number) => {
    const { data } = await api.post<ChatResponse>('/chat', {
      child_id: childId,
      message,
      conversation_id: conversationId,
    })
    return data
  },

  getTodayStats: async (childId: number) => {
    const { data } = await api.get<TodayStats>(`/chat/today/${childId}`)
    return data
  },

  getConversations: async (childId: number, parentId: number, limit = 20, offset = 0) => {
    const { data } = await api.get<Conversation[]>(
      `/chat/conversations/${childId}?parent_id=${parentId}&limit=${limit}&offset=${offset}`
    )
    return data
  },

  getConversation: async (conversationId: number, parentId: number) => {
    const { data } = await api.get<Conversation & { messages: Message[] }>(
      `/chat/conversation/${conversationId}?parent_id=${parentId}`
    )
    return data
  },
}

// Admin API
export const adminApi = {
  getStats: async (adminId: number) => {
    const { data } = await api.get<AdminStats>(`/admin/stats?admin_id=${adminId}`)
    return data
  },

  getUsers: async (adminId: number, limit = 50, offset = 0) => {
    const { data } = await api.get<UserListItem[]>(
      `/admin/users?admin_id=${adminId}&limit=${limit}&offset=${offset}`
    )
    return data
  },

  updateUserTier: async (adminId: number, userId: number, tier: string) => {
    const { data } = await api.patch(
      `/admin/users/${userId}/subscription?admin_id=${adminId}&tier=${tier}`
    )
    return data
  },

  toggleUserActive: async (adminId: number, userId: number) => {
    const { data } = await api.patch(
      `/admin/users/${userId}/toggle-active?admin_id=${adminId}`
    )
    return data
  },

  getFlaggedConversations: async (adminId: number, limit = 20) => {
    const { data } = await api.get(
      `/admin/flagged-conversations?admin_id=${adminId}&limit=${limit}`
    )
    return data
  },

  getConfig: async (adminId: number) => {
    const { data } = await api.get<SystemConfig>(`/admin/config?admin_id=${adminId}`)
    return data
  },

  updateConfig: async (adminId: number, config: SystemConfig) => {
    const { data } = await api.patch(`/admin/config?admin_id=${adminId}`, config)
    return data
  },

  createAdmin: async (email: string, displayName = 'Admin') => {
    const { data } = await api.post(
      `/admin/create-admin?email=${encodeURIComponent(email)}&display_name=${encodeURIComponent(displayName)}`
    )
    return data
  },
}
