import Foundation

class APIClient: ObservableObject {
    // For simulator, use localhost. For device, use your machine's IP
    #if targetEnvironment(simulator)
    private let baseURL = "http://localhost:8000/api"
    #else
    private let baseURL = "http://192.168.1.100:8000/api"  // Change to your machine's IP
    #endif

    private let session: URLSession

    // Reference to AuthManager for Firebase token (set via environment)
    weak var authManager: AuthManager?

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Request Helper with Auth

    private func createRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add Firebase auth token if available
        if let token = authManager?.firebaseIdToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - Firebase Auth API

    /// Login with Firebase ID token - syncs with backend
    func firebaseLogin(idToken: String, displayName: String?) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/firebase-login")!
        var request = createRequest(url: url, method: "POST")

        let body = FirebaseLoginRequest(idToken: idToken, displayName: displayName)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(User.self, from: data)
    }

    /// Get current user profile using Firebase auth token
    func getMe() async throws -> User {
        let url = URL(string: "\(baseURL)/auth/me")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(User.self, from: data)
    }

    // MARK: - Legacy Auth API (MVP fallback)

    func login(email: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/login?email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email)")!
        var request = createRequest(url: url, method: "POST")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func register(email: String, displayName: String?) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = createRequest(url: url, method: "POST")

        let body = RegisterRequest(email: email, displayName: displayName)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func createAdmin(email: String, displayName: String = "Admin") async throws -> User {
        let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        let encodedName = displayName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? displayName
        let url = URL(string: "\(baseURL)/admin/create-admin?email=\(encodedEmail)&display_name=\(encodedName)")!
        var request = createRequest(url: url, method: "POST")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func kidLogin(pin: String) async throws -> KidLoginResponse {
        let url = URL(string: "\(baseURL)/auth/kid-login")!
        var request = createRequest(url: url, method: "POST")

        let body = KidLoginRequest(pin: pin)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(KidLoginResponse.self, from: data)
    }

    // MARK: - Children API
    func getChildren(parentId: Int) async throws -> [ChildWithStats] {
        let url = URL(string: "\(baseURL)/children?parent_id=\(parentId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode([ChildWithStats].self, from: data)
    }

    func createChild(parentId: Int, name: String, age: Int, interests: [String]? = nil) async throws -> Child {
        let url = URL(string: "\(baseURL)/children?parent_id=\(parentId)")!
        var request = createRequest(url: url, method: "POST")

        let body = CreateChildRequest(name: name, age: age, interests: interests)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(Child.self, from: data)
    }

    func getChild(childId: Int, parentId: Int) async throws -> ChildWithStats {
        let url = URL(string: "\(baseURL)/children/\(childId)?parent_id=\(parentId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(ChildWithStats.self, from: data)
    }

    func regeneratePin(childId: Int, parentId: Int) async throws -> Child {
        let url = URL(string: "\(baseURL)/children/\(childId)/regenerate-pin?parent_id=\(parentId)")!
        let request = createRequest(url: url, method: "POST")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(Child.self, from: data)
    }

    // MARK: - Chat API
    func sendMessage(childId: Int, message: String, conversationId: Int? = nil) async throws -> ChatResponse {
        let url = URL(string: "\(baseURL)/chat")!
        var request = createRequest(url: url, method: "POST")

        let body = SendMessageRequest(childId: childId, message: message, conversationId: conversationId)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(ChatResponse.self, from: data)
    }

    func getTodayStats(childId: Int) async throws -> TodayStats {
        let url = URL(string: "\(baseURL)/chat/today/\(childId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(TodayStats.self, from: data)
    }

    func getConversations(childId: Int, parentId: Int, limit: Int = 20, offset: Int = 0) async throws -> [Conversation] {
        let url = URL(string: "\(baseURL)/chat/conversations/\(childId)?parent_id=\(parentId)&limit=\(limit)&offset=\(offset)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode([Conversation].self, from: data)
    }

    func getConversation(conversationId: Int, parentId: Int) async throws -> ConversationWithMessages {
        let url = URL(string: "\(baseURL)/chat/conversation/\(conversationId)?parent_id=\(parentId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(ConversationWithMessages.self, from: data)
    }

    // MARK: - Admin API
    func getAdminStats(adminId: Int) async throws -> AdminStats {
        let url = URL(string: "\(baseURL)/admin/stats?admin_id=\(adminId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(AdminStats.self, from: data)
    }

    func getUsers(adminId: Int, limit: Int = 50, offset: Int = 0) async throws -> [UserListItem] {
        let url = URL(string: "\(baseURL)/admin/users?admin_id=\(adminId)&limit=\(limit)&offset=\(offset)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode([UserListItem].self, from: data)
    }

    func getSystemConfig(adminId: Int) async throws -> SystemConfig {
        let url = URL(string: "\(baseURL)/admin/config?admin_id=\(adminId)")!
        let request = createRequest(url: url, method: "GET")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response)
        return try JSONDecoder().decode(SystemConfig.self, from: data)
    }

    func updateUserTier(adminId: Int, userId: Int, tier: String) async throws {
        let url = URL(string: "\(baseURL)/admin/users/\(userId)/subscription?admin_id=\(adminId)&tier=\(tier)")!
        let request = createRequest(url: url, method: "PATCH")

        let (_, response) = try await session.data(for: request)
        try checkResponse(response)
    }

    func toggleUserActive(adminId: Int, userId: Int) async throws {
        let url = URL(string: "\(baseURL)/admin/users/\(userId)/toggle-active?admin_id=\(adminId)")!
        let request = createRequest(url: url, method: "PATCH")

        let (_, response) = try await session.data(for: request)
        try checkResponse(response)
    }

    // MARK: - Helper
    private func checkResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error (status: \(statusCode))"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
