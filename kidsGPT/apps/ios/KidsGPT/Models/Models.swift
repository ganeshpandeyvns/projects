import Foundation

// MARK: - User Models
struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let displayName: String?
    let role: String
    let subscriptionTier: String
    let isActive: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, email, role
        case displayName = "display_name"
        case subscriptionTier = "subscription_tier"
        case isActive = "is_active"
        case createdAt = "created_at"
    }

    var isAdmin: Bool { role.lowercased() == "admin" }
    var isParent: Bool { role.lowercased() == "parent" }
}

// MARK: - Child Models
struct Child: Codable, Identifiable {
    let id: Int
    let parentId: Int
    let name: String
    let age: Int
    let loginPin: String  // 6-digit PIN for kid login
    let avatarId: String?
    let interests: [String]?
    let learningGoals: [String]?
    let dailyMessageLimit: Int
    let messagesToday: Int
    let lastMessageDate: String?
    let isActive: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, age, interests
        case parentId = "parent_id"
        case loginPin = "login_pin"
        case avatarId = "avatar_id"
        case learningGoals = "learning_goals"
        case dailyMessageLimit = "daily_message_limit"
        case messagesToday = "messages_today"
        case lastMessageDate = "last_message_date"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct ChildWithStats: Codable, Identifiable {
    let id: Int
    let parentId: Int
    let name: String
    let age: Int
    let loginPin: String  // 6-digit PIN for kid login
    let avatarId: String?
    let interests: [String]?
    let learningGoals: [String]?
    let dailyMessageLimit: Int
    let messagesToday: Int
    let lastMessageDate: String?
    let isActive: Bool
    let createdAt: String
    let totalConversations: Int
    let totalMessages: Int
    let canSendMessage: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, age, interests
        case parentId = "parent_id"
        case loginPin = "login_pin"
        case avatarId = "avatar_id"
        case learningGoals = "learning_goals"
        case dailyMessageLimit = "daily_message_limit"
        case messagesToday = "messages_today"
        case lastMessageDate = "last_message_date"
        case isActive = "is_active"
        case createdAt = "created_at"
        case totalConversations = "total_conversations"
        case totalMessages = "total_messages"
        case canSendMessage = "can_send_message"
    }

    var progressPercentage: Double {
        guard dailyMessageLimit > 0 else { return 0 }
        return Double(messagesToday) / Double(dailyMessageLimit) * 100
    }

    var messagesRemaining: Int {
        max(0, dailyMessageLimit - messagesToday)
    }
}

// MARK: - Chat Models
struct Message: Codable, Identifiable {
    let id: Int
    let conversationId: Int
    let role: String
    let content: String
    let isFlagged: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, role, content
        case conversationId = "conversation_id"
        case isFlagged = "is_flagged"
        case createdAt = "created_at"
    }

    var isChild: Bool { role == "child" }
    var isAssistant: Bool { role == "assistant" }
}

struct Conversation: Codable, Identifiable {
    let id: Int
    let childId: Int
    let title: String?
    let startedAt: String
    let endedAt: String?
    let isFlagged: Bool
    let messageCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title
        case childId = "child_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case isFlagged = "is_flagged"
        case messageCount = "message_count"
    }
}

struct ConversationWithMessages: Codable, Identifiable {
    let id: Int
    let childId: Int
    let title: String?
    let startedAt: String
    let endedAt: String?
    let isFlagged: Bool
    let messageCount: Int
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case id, title, messages
        case childId = "child_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case isFlagged = "is_flagged"
        case messageCount = "message_count"
    }
}

struct ChatResponse: Codable {
    let conversationId: Int
    let message: Message
    let response: Message
    let messagesRemainingToday: Int
    let safetyNote: String?

    enum CodingKeys: String, CodingKey {
        case message, response
        case conversationId = "conversation_id"
        case messagesRemainingToday = "messages_remaining_today"
        case safetyNote = "safety_note"
    }
}

struct TodayStats: Codable {
    let childId: Int
    let childName: String
    let messagesSentToday: Int
    let dailyLimit: Int
    let messagesRemaining: Int
    let canSendMessage: Bool

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case childName = "child_name"
        case messagesSentToday = "messages_sent_today"
        case dailyLimit = "daily_limit"
        case messagesRemaining = "messages_remaining"
        case canSendMessage = "can_send_message"
    }
}

// MARK: - Admin Models
struct AdminStats: Codable {
    let totalUsers: Int
    let totalChildren: Int
    let totalConversations: Int
    let totalMessages: Int
    let messagesToday: Int
    let activeUsersToday: Int
    let flaggedConversations: Int

    enum CodingKeys: String, CodingKey {
        case totalUsers = "total_users"
        case totalChildren = "total_children"
        case totalConversations = "total_conversations"
        case totalMessages = "total_messages"
        case messagesToday = "messages_today"
        case activeUsersToday = "active_users_today"
        case flaggedConversations = "flagged_conversations"
    }
}

struct UserListItem: Codable, Identifiable {
    let id: Int
    let email: String
    let displayName: String?
    let role: String
    let subscriptionTier: String
    let isActive: Bool
    let createdAt: String
    let childrenCount: Int
    let totalMessages: Int

    enum CodingKeys: String, CodingKey {
        case id, email, role
        case displayName = "display_name"
        case subscriptionTier = "subscription_tier"
        case isActive = "is_active"
        case createdAt = "created_at"
        case childrenCount = "children_count"
        case totalMessages = "total_messages"
    }
}

struct SystemConfig: Codable {
    var aiProvider: String
    var defaultDailyLimit: Int
    var maxChildrenFree: Int
    var maxChildrenBasic: Int
    var maxChildrenPremium: Int
    var contentFilterLevel: String

    enum CodingKeys: String, CodingKey {
        case aiProvider = "ai_provider"
        case defaultDailyLimit = "default_daily_limit"
        case maxChildrenFree = "max_children_free"
        case maxChildrenBasic = "max_children_basic"
        case maxChildrenPremium = "max_children_premium"
        case contentFilterLevel = "content_filter_level"
    }
}

// MARK: - Request Models
struct CreateChildRequest: Codable {
    let name: String
    let age: Int
    let interests: [String]?
}

struct SendMessageRequest: Codable {
    let childId: Int
    let message: String
    let conversationId: Int?

    enum CodingKeys: String, CodingKey {
        case message
        case childId = "child_id"
        case conversationId = "conversation_id"
    }
}

struct RegisterRequest: Codable {
    let email: String
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case email
        case displayName = "display_name"
    }
}

// MARK: - Kid Login Models
struct KidLoginRequest: Codable {
    let pin: String
}

struct KidLoginResponse: Codable {
    let childId: Int
    let childName: String
    let age: Int
    let avatarId: String?
    let dailyLimit: Int
    let messagesRemaining: Int
    let canSendMessage: Bool
    let parentName: String?

    enum CodingKeys: String, CodingKey {
        case age
        case childId = "child_id"
        case childName = "child_name"
        case avatarId = "avatar_id"
        case dailyLimit = "daily_limit"
        case messagesRemaining = "messages_remaining"
        case canSendMessage = "can_send_message"
        case parentName = "parent_name"
    }
}
