import SwiftUI

struct LandingView: View {
    @Binding var selectedPortal: PortalType?
    @State private var animateBackground = false

    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 32) {
                    // Hero Section
                    HeroSection()

                    // Portal Cards
                    VStack(spacing: 16) {
                        Text("Choose Your Portal")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        ForEach(PortalType.allCases, id: \.self) { portal in
                            PortalCard(portal: portal) {
                                withAnimation(.bouncy) {
                                    selectedPortal = portal
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Trust Badges
                    TrustBadgesView()

                    // Features Section
                    FeaturesSection()

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 16) {
            // Animated Mascot
            ZStack {
                Circle()
                    .fill(AppColors.kidsGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "6366f1").opacity(0.4), radius: 20, x: 0, y: 10)

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
                Text("KidsGPT")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(AppColors.kidsGradient)

                Text("Safe AI Learning Companion")
                    .font(.headline)
                    .foregroundColor(AppColors.textSecondary)

                Text("Where curiosity meets safety")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary.opacity(0.8))
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Portal Card
struct PortalCard: View {
    let portal: PortalType
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: portal.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                        .shadow(color: portal.gradient.first!.opacity(0.4), radius: 10, x: 0, y: 5)

                    Text(portal.emoji)
                        .font(.system(size: 28))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(portal.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(portal.subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(LinearGradient(colors: portal.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .shadow(color: portal.gradient.first!.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(colors: portal.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isPressed ? 2 : 0
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Trust Badges
struct TrustBadgesView: View {
    let badges = [
        ("checkmark.shield.fill", "COPPA Compliant"),
        ("lock.shield.fill", "End-to-End Encrypted"),
        ("star.shield.fill", "SOC 2 Type II")
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text("Enterprise-Grade Security")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: 16) {
                ForEach(badges, id: \.1) { icon, text in
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(AppColors.success)
                        Text(text)
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "10b981").opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Features Section
struct FeaturesSection: View {
    let features = [
        ("brain.head.profile", "Smart Learning", "AI adapts to each child's learning style", Color(hex: "6366f1")),
        ("shield.lefthalf.filled", "Always Safe", "Multi-layer content filtering", Color(hex: "10b981")),
        ("chart.line.uptrend.xyaxis", "Track Progress", "Detailed insights for parents", Color(hex: "f59e0b")),
        ("sparkles", "Fun & Engaging", "Learning through conversation", Color(hex: "ec4899"))
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Why Choose KidsGPT?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(features, id: \.1) { icon, title, desc, color in
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.15))
                                .frame(width: 50, height: 50)

                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundColor(color)
                        }

                        VStack(spacing: 4) {
                            Text(title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)

                            Text(desc)
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "f8fafc"), Color(hex: "eff6ff"), Color(hex: "f5f3ff")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating shapes
            GeometryReader { geo in
                FloatingShape(size: 200, color: Color(hex: "6366f1").opacity(0.1))
                    .position(x: geo.size.width * 0.1, y: geo.size.height * 0.2)

                FloatingShape(size: 150, color: Color(hex: "a855f7").opacity(0.1))
                    .position(x: geo.size.width * 0.9, y: geo.size.height * 0.3)

                FloatingShape(size: 100, color: Color(hex: "ec4899").opacity(0.1))
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.8)
            }
        }
    }
}

struct FloatingShape: View {
    let size: CGFloat
    let color: Color
    @State private var animate = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 30)
            .offset(y: animate ? -20 : 20)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.bouncy, value: configuration.isPressed)
    }
}

#Preview {
    LandingView(selectedPortal: .constant(nil))
}
