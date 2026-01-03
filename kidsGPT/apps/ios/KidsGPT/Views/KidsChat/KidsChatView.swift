import SwiftUI

struct KidsChatView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient

    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var conversationId: Int? = nil
    @State private var messagesRemaining = 20
    @State private var showCelebration = false
    @State private var showChildSelector = false

    var body: some View {
        ZStack {
            // Background
            KidsChatBackground()

            VStack(spacing: 0) {
                // Header
                KidsChatHeader(
                    childName: authManager.selectedChild?.name ?? "Friend",
                    messagesRemaining: messagesRemaining,
                    dailyLimit: authManager.selectedChild?.dailyMessageLimit ?? 20,
                    onLogout: { authManager.logout() },
                    onSelectChild: { showChildSelector = true }
                )

                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message
                            if messages.isEmpty {
                                WelcomeMessage(childName: authManager.selectedChild?.name ?? "Friend")
                            }

                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }

                            // Typing indicator
                            if isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Quick Suggestions
                if messages.isEmpty {
                    QuickSuggestionsBar(onSelect: sendMessage)
                }

                // Input Bar
                ChatInputBar(
                    text: $inputText,
                    isDisabled: isTyping || messagesRemaining <= 0,
                    onSend: { sendMessage(inputText) }
                )
            }

            // Celebration Overlay
            if showCelebration {
                CelebrationView()
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCelebration = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showChildSelector) {
            ChildSelectorSheet()
        }
        .onAppear {
            loadStats()
        }
    }

    private func loadStats() {
        guard let child = authManager.selectedChild else { return }
        Task {
            do {
                let stats = try await apiClient.getTodayStats(childId: child.id)
                await MainActor.run {
                    messagesRemaining = stats.messagesRemaining
                }
            } catch {
                print("Failed to load stats: \(error)")
            }
        }
    }

    private func sendMessage(_ text: String) {
        guard !text.isEmpty, let child = authManager.selectedChild else { return }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(id: UUID(), role: .child, content: trimmedText)
        messages.append(userMessage)
        inputText = ""

        // Show celebration on first message
        if messages.count == 1 {
            showCelebration = true
        }

        // Show typing indicator
        isTyping = true

        // Send to API
        Task {
            do {
                let response = try await apiClient.sendMessage(
                    childId: child.id,
                    message: trimmedText,
                    conversationId: conversationId
                )

                await MainActor.run {
                    conversationId = response.conversationId
                    messagesRemaining = response.messagesRemainingToday

                    let assistantMessage = ChatMessage(
                        id: UUID(),
                        role: .assistant,
                        content: response.response.content
                    )
                    messages.append(assistantMessage)
                    isTyping = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = ChatMessage(
                        id: UUID(),
                        role: .assistant,
                        content: "Oops! Something went wrong. Let's try again! 🌟"
                    )
                    messages.append(errorMessage)
                    isTyping = false
                }
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let role: MessageRole
    let content: String

    enum MessageRole {
        case child, assistant
    }
}

// MARK: - Kids Chat Header
struct KidsChatHeader: View {
    let childName: String
    let messagesRemaining: Int
    let dailyLimit: Int
    let onLogout: () -> Void
    let onSelectChild: () -> Void

    var progress: Double {
        guard dailyLimit > 0 else { return 0 }
        return Double(dailyLimit - messagesRemaining) / Double(dailyLimit)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Mascot
                ZStack {
                    Circle()
                        .fill(AppColors.kidsGradient)
                        .frame(width: 50, height: 50)

                    Text("✨")
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi, \(childName)!")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Let's learn together!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Settings Menu
                Menu {
                    Button(action: onSelectChild) {
                        Label("Switch Child", systemImage: "person.2")
                    }
                    Button(role: .destructive, action: onLogout) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }

            // Progress bar
            HStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(4)

                Text("\(messagesRemaining) left")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(AppColors.kidsGradient)
    }
}

// MARK: - Kids Chat Background
struct KidsChatBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(hex: "faf5ff"), Color(hex: "f0f9ff")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Welcome Message
struct WelcomeMessage: View {
    let childName: String
    @State private var animate = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.kidsGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "6366f1").opacity(0.3), radius: 20, x: 0, y: 10)

                Text("✨")
                    .font(.system(size: 50))
                    .offset(y: animate ? -5 : 5)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }

            VStack(spacing: 8) {
                Text("Hi there, \(childName)! 👋")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text("I'm Sparky, your learning buddy!")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                Text("Ask me anything - I love curious questions!")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary.opacity(0.8))
            }
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .child {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .child ? .trailing : .leading, spacing: 4) {
                if message.role == .assistant {
                    HStack(spacing: 6) {
                        Text("✨")
                            .font(.caption)
                        Text("Sparky")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .child
                            ? AnyShapeStyle(AppColors.childBubble)
                            : AnyShapeStyle(Color(hex: "f1f5f9"))
                    )
                    .foregroundColor(message.role == .child ? .white : AppColors.textPrimary)
                    .cornerRadius(20, corners: message.role == .child
                        ? [.topLeft, .topRight, .bottomLeft]
                        : [.topLeft, .topRight, .bottomRight]
                    )
            }

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Quick Suggestions Bar
struct QuickSuggestionsBar: View {
    let onSelect: (String) -> Void

    let suggestions = [
        ("🦕", "Dinosaurs", "Tell me about T-Rex!", Color(hex: "10b981")),
        ("🚀", "Space", "How big is the sun?", Color(hex: "6366f1")),
        ("🔢", "Math", "Help me with math!", Color(hex: "f59e0b")),
        ("📚", "Stories", "Tell me a story!", Color(hex: "ec4899"))
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestions, id: \.1) { emoji, label, prompt, color in
                    Button(action: { onSelect(prompt) }) {
                        HStack(spacing: 8) {
                            Text(emoji)
                                .font(.title3)
                            Text(label)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [color.opacity(0.15), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(color)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.8))
    }
}

// MARK: - Chat Input Bar
struct ChatInputBar: View {
    @Binding var text: String
    let isDisabled: Bool
    let onSend: () -> Void

    @State private var showEmojiPicker = false

    let quickEmojis = ["😊", "🎉", "⭐", "❤️", "👍", "🌈"]

    var body: some View {
        VStack(spacing: 0) {
            // Emoji picker
            if showEmojiPicker {
                HStack(spacing: 16) {
                    ForEach(quickEmojis, id: \.self) { emoji in
                        Button(action: { text += emoji }) {
                            Text(emoji)
                                .font(.title2)
                        }
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "f8fafc"))
            }

            // Input
            HStack(spacing: 12) {
                Button(action: { showEmojiPicker.toggle() }) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundColor(showEmojiPicker ? Color(hex: "6366f1") : AppColors.textSecondary)
                }

                TextField("Ask Sparky something fun!", text: $text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "f1f5f9"))
                    .cornerRadius(24)
                    .disabled(isDisabled)

                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(
                                text.isEmpty || isDisabled
                                    ? AnyShapeStyle(Color.gray.opacity(0.3))
                                    : AnyShapeStyle(AppColors.kidsGradient)
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: "paperplane.fill")
                            .font(.body)
                            .foregroundColor(.white)
                            .offset(x: 1, y: -1)
                    }
                }
                .disabled(text.isEmpty || isDisabled)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: [CGFloat] = [0, 0, 0]

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Text("✨")
                    .font(.caption)

                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color(hex: "6366f1"))
                            .frame(width: 8, height: 8)
                            .offset(y: animationOffset[index])
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "f1f5f9"))
            .cornerRadius(20)

            Spacer()
        }
        .onAppear {
            animateTyping()
        }
    }

    private func animateTyping() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.15)
            ) {
                animationOffset[i] = -6
            }
        }
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)

            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))

                Text("Great question!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Child Selector Sheet
struct ChildSelectorSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient
    @Environment(\.dismiss) var dismiss

    @State private var children: [ChildWithStats] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else if children.isEmpty {
                    VStack(spacing: 16) {
                        Text("No children profiles yet")
                            .foregroundColor(AppColors.textSecondary)
                        Text("Ask a parent to add you!")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                    }
                } else {
                    List(children) { child in
                        Button(action: {
                            authManager.selectChild(child)
                            dismiss()
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.kidsGradient)
                                        .frame(width: 50, height: 50)
                                    Text(String(child.name.prefix(1)).uppercased())
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading) {
                                    Text(child.name)
                                        .font(.headline)
                                    Text("\(child.age) years old")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }

                                Spacer()

                                if authManager.selectedChild?.id == child.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.success)
                                }
                            }
                        }
                        .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .navigationTitle("Select Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            loadChildren()
        }
    }

    private func loadChildren() {
        guard let user = authManager.currentUser else { return }
        Task {
            do {
                let result = try await apiClient.getChildren(parentId: user.id)
                await MainActor.run {
                    children = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    KidsChatView()
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
