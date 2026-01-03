import SwiftUI

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color(hex: "1e293b").opacity(0.9))
            .cornerRadius(16)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "f1f5f9"))
                    .frame(width: 100, height: 100)

                Text(icon)
                    .font(.system(size: 50))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppColors.kidsGradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(32)
    }
}

// MARK: - Success Toast
struct SuccessToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(AppColors.success)

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppColors.success.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color(hex: "ef4444"))
        .cornerRadius(12)
    }
}

// MARK: - Badge
struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let name: String
    let size: CGFloat
    let gradient: LinearGradient

    init(name: String, size: CGFloat = 50, gradient: LinearGradient = AppColors.kidsGradient) {
        self.name = name
        self.size = size
        self.gradient = gradient
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)

            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "f1f5f9"),
                Color(hex: "e2e8f0"),
                Color(hex: "f1f5f9")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(Rectangle())
        .offset(x: isAnimating ? 200 : -200)
        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Skeleton Card
struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: "e2e8f0"))
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "e2e8f0"))
                        .frame(width: 120, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "e2e8f0"))
                        .frame(width: 80, height: 10)
                }
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "e2e8f0"))
                .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        EmptyStateView(
            icon: "🎉",
            title: "No Messages",
            message: "Start chatting with Sheldon!",
            action: {},
            actionTitle: "Start Chat"
        )

        SuccessToast(message: "Message sent successfully!")

        ErrorBanner(message: "Connection failed", onDismiss: {})

        HStack {
            Badge(text: "Premium", color: Color(hex: "f59e0b"))
            Badge(text: "Active", color: AppColors.success)
        }

        AvatarView(name: "Alex", size: 60)

        SkeletonCard()
    }
    .padding()
}
