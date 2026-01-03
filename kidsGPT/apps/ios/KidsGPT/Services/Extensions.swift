import SwiftUI

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Colors
struct AppColors {
    // Primary Gradients
    static let kidsGradient = LinearGradient(
        colors: [Color(hex: "6366f1"), Color(hex: "a855f7")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let parentGradient = LinearGradient(
        colors: [Color(hex: "8b5cf6"), Color(hex: "ec4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let adminGradient = LinearGradient(
        colors: [Color(hex: "3b82f6"), Color(hex: "06b6d4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Accent Colors
    static let primary = Color(hex: "6366f1")
    static let secondary = Color(hex: "a855f7")
    static let accent = Color(hex: "f59e0b")
    static let success = Color(hex: "10b981")
    static let warning = Color(hex: "f59e0b")
    static let danger = Color(hex: "ef4444")

    // Neutral Colors
    static let background = Color(hex: "f8fafc")
    static let card = Color.white
    static let textPrimary = Color(hex: "1e293b")
    static let textSecondary = Color(hex: "64748b")
    static let border = Color(hex: "e2e8f0")

    // Chat Colors
    static let childBubble = LinearGradient(
        colors: [Color(hex: "6366f1"), Color(hex: "a855f7")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let assistantBubble = Color(hex: "f1f5f9")
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
    }

    func premiumCardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    .shadow(color: Color(hex: "6366f1").opacity(0.1), radius: 20, x: 0, y: 10)
            )
    }

    func glassStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

// MARK: - Date Formatter
extension String {
    func toFormattedDate() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return self
    }
}
