import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient

    @State private var children: [ChildWithStats] = []
    @State private var isLoading = true
    @State private var showAddChild = false
    @State private var selectedChild: ChildWithStats? = nil

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "fdf4ff"), Color(hex: "faf5ff"), Color(hex: "f5f3ff")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ParentHeader(
                    userName: authManager.currentUser?.displayName ?? "Parent",
                    subscriptionTier: authManager.currentUser?.subscriptionTier ?? "free",
                    onLogout: { authManager.logout() }
                )

                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Stats Overview
                            StatsOverview(children: children)

                            // Children Section
                            ChildrenSection(
                                children: children,
                                onAddChild: { showAddChild = true },
                                onSelectChild: { child in selectedChild = child }
                            )

                            // Subscription Section
                            SubscriptionSection(tier: authManager.currentUser?.subscriptionTier ?? "free")
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddChild) {
            AddChildSheet(onSuccess: loadChildren)
        }
        .sheet(item: $selectedChild) { child in
            ChildDetailSheet(child: child, onClose: { selectedChild = nil })
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

// MARK: - Parent Header
struct ParentHeader: View {
    let userName: String
    let subscriptionTier: String
    let onLogout: () -> Void

    var tierColor: Color {
        switch subscriptionTier.lowercased() {
        case "premium": return Color(hex: "f59e0b")
        case "basic": return Color(hex: "8b5cf6")
        default: return Color(hex: "64748b")
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            // Tier Badge
            Text(subscriptionTier.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(tierColor)
                .foregroundColor(.white)
                .cornerRadius(20)

            // Logout
            Button(action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(AppColors.parentGradient)
    }
}

// MARK: - Stats Overview
struct StatsOverview: View {
    let children: [ChildWithStats]

    var totalMessages: Int {
        children.reduce(0) { $0 + $1.totalMessages }
    }

    var totalConversations: Int {
        children.reduce(0) { $0 + $1.totalConversations }
    }

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "person.2.fill",
                value: "\(children.count)",
                label: "Children",
                color: Color(hex: "8b5cf6")
            )

            StatCard(
                icon: "bubble.left.and.bubble.right.fill",
                value: "\(totalConversations)",
                label: "Chats",
                color: Color(hex: "ec4899")
            )

            StatCard(
                icon: "text.bubble.fill",
                value: "\(totalMessages)",
                label: "Messages",
                color: Color(hex: "6366f1")
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Children Section
struct ChildrenSection: View {
    let children: [ChildWithStats]
    let onAddChild: () -> Void
    let onSelectChild: (ChildWithStats) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Children")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: onAddChild) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Child")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "8b5cf6"))
                }
            }

            if children.isEmpty {
                EmptyChildrenCard(onAddChild: onAddChild)
            } else {
                ForEach(children) { child in
                    ChildCard(child: child)
                        .onTapGesture { onSelectChild(child) }
                }
            }
        }
    }
}

struct EmptyChildrenCard: View {
    let onAddChild: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "8b5cf6").opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "8b5cf6"))
            }

            Text("No children yet")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("Add your first child to get started!")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            Button(action: onAddChild) {
                Text("Add Child")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.parentGradient)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct ChildCard: View {
    let child: ChildWithStats

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.parentGradient)
                    .frame(width: 56, height: 56)

                Text(String(child.name.prefix(1)).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text("\(child.age) years old")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                // Progress
                HStack(spacing: 8) {
                    ProgressView(value: child.progressPercentage / 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "8b5cf6")))
                        .frame(width: 80)

                    Text("\(child.messagesRemaining) left today")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(child.totalMessages)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "8b5cf6"))

                Text("messages")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Subscription Section
struct SubscriptionSection: View {
    let tier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tier.capitalized)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        if tier.lowercased() == "premium" {
                            Text("✨")
                        }
                    }

                    Text(tierDescription)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                if tier.lowercased() != "premium" {
                    Button(action: {}) {
                        Text("Upgrade")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "f59e0b"), Color(hex: "f97316")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "fef3c7").opacity(0.5), Color(hex: "fde68a").opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "f59e0b").opacity(0.3), lineWidth: 1)
            )
        }
    }

    var tierDescription: String {
        switch tier.lowercased() {
        case "premium": return "Unlimited messages, all features"
        case "basic": return "50 messages/day, basic features"
        default: return "20 messages/day, limited features"
        }
    }
}

// MARK: - Add Child Sheet
struct AddChildSheet: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient
    @Environment(\.dismiss) var dismiss

    let onSuccess: () -> Void

    @State private var name = ""
    @State private var age: Double = 8
    @State private var selectedInterests: Set<String> = []
    @State private var isLoading = false
    @State private var error = ""

    let interests = ["Science", "Math", "Stories", "Animals", "Space", "Art", "Music", "Sports"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Child's Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)

                        TextField("Enter name", text: $name)
                            .textFieldStyle(PremiumTextFieldStyle())
                    }

                    // Age
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Age")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textSecondary)

                            Spacer()

                            Text("\(Int(age)) years")
                                .font(.headline)
                                .foregroundColor(Color(hex: "8b5cf6"))
                        }

                        Slider(value: $age, in: 3...13, step: 1)
                            .tint(Color(hex: "8b5cf6"))
                    }

                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(interests, id: \.self) { interest in
                                Button(action: {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                }) {
                                    Text(interest)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedInterests.contains(interest)
                                                ? Color(hex: "8b5cf6")
                                                : Color(hex: "f1f5f9")
                                        )
                                        .foregroundColor(
                                            selectedInterests.contains(interest)
                                                ? .white
                                                : AppColors.textPrimary
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    if !error.isEmpty {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Submit Button
                    Button(action: createChild) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Child")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            name.isEmpty
                                ? AnyShapeStyle(Color.gray.opacity(0.3))
                                : AnyShapeStyle(AppColors.parentGradient)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(name.isEmpty || isLoading)
                }
                .padding(24)
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func createChild() {
        guard let user = authManager.currentUser, !name.isEmpty else { return }

        isLoading = true
        error = ""

        Task {
            do {
                _ = try await apiClient.createChild(
                    parentId: user.id,
                    name: name,
                    age: Int(age),
                    interests: Array(selectedInterests)
                )
                await MainActor.run {
                    onSuccess()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to add child. Please try again."
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Child Detail Sheet
struct ChildDetailSheet: View {
    let child: ChildWithStats
    let onClose: () -> Void

    @EnvironmentObject var apiClient: APIClient
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var conversations: [Conversation] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.parentGradient)
                                .frame(width: 80, height: 80)

                            Text(String(child.name.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 4) {
                            Text(child.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(child.age) years old")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.top)

                    // Stats
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(child.totalMessages)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "8b5cf6"))
                            Text("Messages")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack {
                            Text("\(child.totalConversations)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "ec4899"))
                            Text("Chats")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Divider()
                            .frame(height: 40)

                        VStack {
                            Text("\(child.messagesRemaining)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "10b981"))
                            Text("Left Today")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)

                    // Interests
                    if let interests = child.interests, !interests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                                ForEach(interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "8b5cf6").opacity(0.1))
                                        .foregroundColor(Color(hex: "8b5cf6"))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Recent Conversations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Conversations")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if conversations.isEmpty {
                            Text("No conversations yet")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(conversations) { conversation in
                                ConversationRow(conversation: conversation)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .background(Color(hex: "f8fafc").ignoresSafeArea())
            .navigationTitle("Child Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onClose()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadConversations()
        }
    }

    private func loadConversations() {
        guard let user = authManager.currentUser else { return }
        Task {
            do {
                let result = try await apiClient.getConversations(
                    childId: child.id,
                    parentId: user.id,
                    limit: 10
                )
                await MainActor.run {
                    conversations = result
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

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title ?? "Conversation")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)

                Text(conversation.startedAt.toFormattedDate())
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("\(conversation.messageCount)")
                    .font(.caption)
                    .fontWeight(.medium)
                Image(systemName: "bubble.left.fill")
                    .font(.caption2)
            }
            .foregroundColor(AppColors.textSecondary)

            if conversation.isFlagged {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: "f59e0b"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    ParentDashboardView()
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
