import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient

    @State private var stats: AdminStats? = nil
    @State private var users: [UserListItem] = []
    @State private var config: SystemConfig? = nil
    @State private var isLoading = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "eff6ff"), Color(hex: "f0f9ff"), Color(hex: "ecfeff")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                AdminHeader(
                    userName: authManager.currentUser?.displayName ?? "Admin",
                    onLogout: { authManager.logout() }
                )

                // Tab Bar
                AdminTabBar(selectedTab: $selectedTab)

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    TabView(selection: $selectedTab) {
                        // Overview Tab
                        AdminOverviewTab(stats: stats)
                            .tag(0)

                        // Users Tab
                        AdminUsersTab(users: users, onRefresh: loadUsers)
                            .tag(1)

                        // Settings Tab
                        AdminSettingsTab(config: config)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        guard let user = authManager.currentUser else { return }
        Task {
            do {
                async let statsResult = apiClient.getAdminStats(adminId: user.id)
                async let usersResult = apiClient.getUsers(adminId: user.id)
                async let configResult = apiClient.getSystemConfig(adminId: user.id)

                let (s, u, c) = try await (statsResult, usersResult, configResult)

                await MainActor.run {
                    stats = s
                    users = u
                    config = c
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    private func loadUsers() {
        guard let user = authManager.currentUser else { return }
        Task {
            do {
                let result = try await apiClient.getUsers(adminId: user.id)
                await MainActor.run {
                    users = result
                }
            } catch {
                print("Failed to load users: \(error)")
            }
        }
    }
}

// MARK: - Admin Header
struct AdminHeader: View {
    let userName: String
    let onLogout: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "shield.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Admin Panel")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(userName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Spacer()

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
        .background(AppColors.adminGradient)
    }
}

// MARK: - Admin Tab Bar
struct AdminTabBar: View {
    @Binding var selectedTab: Int

    let tabs = [
        ("chart.bar.fill", "Overview"),
        ("person.3.fill", "Users"),
        ("gearshape.fill", "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 6) {
                        Image(systemName: tabs[index].0)
                            .font(.title3)

                        Text(tabs[index].1)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == index ? Color(hex: "3b82f6") : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == index
                            ? Color(hex: "3b82f6").opacity(0.1)
                            : Color.clear
                    )
                }
            }
        }
        .background(Color.white)
    }
}

// MARK: - Overview Tab
struct AdminOverviewTab: View {
    let stats: AdminStats?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let stats = stats {
                    // Main Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        AdminStatCard(
                            icon: "person.3.fill",
                            value: "\(stats.totalUsers)",
                            label: "Total Users",
                            color: Color(hex: "3b82f6")
                        )

                        AdminStatCard(
                            icon: "face.smiling.fill",
                            value: "\(stats.totalChildren)",
                            label: "Children",
                            color: Color(hex: "8b5cf6")
                        )

                        AdminStatCard(
                            icon: "bubble.left.and.bubble.right.fill",
                            value: "\(stats.totalConversations)",
                            label: "Conversations",
                            color: Color(hex: "10b981")
                        )

                        AdminStatCard(
                            icon: "text.bubble.fill",
                            value: "\(stats.totalMessages)",
                            label: "Messages",
                            color: Color(hex: "f59e0b")
                        )
                    }

                    // Today's Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Activity")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: 16) {
                            TodayStatCard(
                                icon: "text.bubble.fill",
                                value: "\(stats.messagesToday)",
                                label: "Messages Today",
                                color: Color(hex: "3b82f6")
                            )

                            TodayStatCard(
                                icon: "person.fill.checkmark",
                                value: "\(stats.activeUsersToday)",
                                label: "Active Users",
                                color: Color(hex: "10b981")
                            )
                        }
                    }

                    // Flagged Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content Moderation")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        HStack {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(stats.flaggedConversations > 0
                                            ? Color(hex: "ef4444").opacity(0.15)
                                            : Color(hex: "10b981").opacity(0.15)
                                        )
                                        .frame(width: 50, height: 50)

                                    Image(systemName: stats.flaggedConversations > 0
                                        ? "exclamationmark.triangle.fill"
                                        : "checkmark.shield.fill"
                                    )
                                    .font(.title3)
                                    .foregroundColor(stats.flaggedConversations > 0
                                        ? Color(hex: "ef4444")
                                        : Color(hex: "10b981")
                                    )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(stats.flaggedConversations)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text("Flagged Conversations")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }

                            Spacer()

                            if stats.flaggedConversations > 0 {
                                Button(action: {}) {
                                    Text("Review")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "ef4444"))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                } else {
                    Text("No data available")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
        }
    }
}

struct AdminStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct TodayStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text(label)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Users Tab
struct AdminUsersTab: View {
    let users: [UserListItem]
    let onRefresh: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search (placeholder)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.textSecondary)

                    Text("Search users...")
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)

                // Users List
                ForEach(users) { user in
                    AdminUserRow(user: user)
                }
            }
            .padding()
        }
        .refreshable {
            onRefresh()
        }
    }
}

struct AdminUserRow: View {
    let user: UserListItem

    var tierColor: Color {
        switch user.subscriptionTier.lowercased() {
        case "premium": return Color(hex: "f59e0b")
        case "basic": return Color(hex: "8b5cf6")
        default: return Color(hex: "64748b")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        user.role.lowercased() == "admin"
                            ? AppColors.adminGradient
                            : AppColors.parentGradient
                    )
                    .frame(width: 50, height: 50)

                Text(String(user.email.prefix(1)).uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(user.displayName ?? user.email)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    if user.role.lowercased() == "admin" {
                        Text("Admin")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "3b82f6"))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                Text(user.email)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: 12) {
                    Label("\(user.childrenCount)", systemImage: "person.fill")
                    Label("\(user.totalMessages)", systemImage: "bubble.left.fill")
                }
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // Tier Badge
            Text(user.subscriptionTier.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tierColor.opacity(0.15))
                .foregroundColor(tierColor)
                .cornerRadius(6)

            // Status
            Circle()
                .fill(user.isActive ? Color(hex: "10b981") : Color(hex: "ef4444"))
                .frame(width: 10, height: 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Settings Tab
struct AdminSettingsTab: View {
    let config: SystemConfig?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let config = config {
                    // AI Provider
                    SettingsCard(title: "AI Provider") {
                        HStack {
                            Text("Current Provider")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(config.aiProvider.capitalized)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "3b82f6"))
                        }
                    }

                    // Message Limits
                    SettingsCard(title: "Message Limits") {
                        VStack(spacing: 12) {
                            SettingsRow(label: "Daily Limit", value: "\(config.defaultDailyLimit)")
                            Divider()
                            SettingsRow(label: "Free Tier Max Children", value: "\(config.maxChildrenFree)")
                            Divider()
                            SettingsRow(label: "Basic Tier Max Children", value: "\(config.maxChildrenBasic)")
                            Divider()
                            SettingsRow(label: "Premium Tier Max Children", value: "\(config.maxChildrenPremium)")
                        }
                    }

                    // Content Filter
                    SettingsCard(title: "Content Safety") {
                        HStack {
                            Text("Filter Level")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(config.contentFilterLevel.capitalized)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: "10b981").opacity(0.15))
                                .foregroundColor(Color(hex: "10b981"))
                                .cornerRadius(6)
                        }
                    }
                } else {
                    Text("Configuration not available")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
        }
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct SettingsRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    AdminPanelView()
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
