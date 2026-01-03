import SwiftUI

// MARK: - Accessibility Helpers

/// Accessibility configuration for the app
struct AppAccessibility {
    // MARK: - Labels

    struct Labels {
        // Landing
        static let kidsPortal = "Kids Zone. Learn and play with Sheldon, your AI learning buddy."
        static let parentPortal = "Parent Hub. Monitor and manage your children's learning."
        static let adminPortal = "Admin Panel. System administration and oversight."

        // Login
        static let emailField = "Email address input field"
        static let nameField = "Name input field"
        static let loginButton = "Continue to login"
        static let registerButton = "Create new account"
        static let backButton = "Go back to portal selection"

        // Kids Chat
        static let chatInput = "Type your message to Sheldon here"
        static let sendButton = "Send message"
        static let emojiButton = "Open emoji picker"
        static let messagesRemaining = { (count: Int) in
            "You have \(count) messages left today"
        }

        // Parent Dashboard
        static let addChildButton = "Add a new child profile"
        static let childCard = { (name: String, age: Int) in
            "\(name), \(age) years old. Tap to view details."
        }

        // Admin
        static let statsCard = { (label: String, value: String) in
            "\(label): \(value)"
        }
    }

    // MARK: - Hints

    struct Hints {
        static let portalCard = "Double tap to select this portal"
        static let chatSend = "Double tap to send your message"
        static let quickSuggestion = "Double tap to ask Sheldon about this topic"
    }

    // MARK: - Announcements

    struct Announcements {
        static let messageSent = "Message sent"
        static let messageReceived = "Sheldon responded"
        static let loginSuccess = "Successfully logged in"
        static let error = { (message: String) in "Error: \(message)" }
    }
}

// MARK: - View Extension for Accessibility

extension View {
    /// Adds standard accessibility configuration for interactive cards
    func accessibleCard(label: String, hint: String = "Double tap to select") -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }

    /// Adds accessibility for input fields
    func accessibleInput(label: String, value: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityValue(value.isEmpty ? "Empty" : value)
    }

    /// Adds accessibility for buttons with custom label
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    /// Announces text to VoiceOver
    func announce(_ text: String) {
        UIAccessibility.post(notification: .announcement, argument: text)
    }
}

// MARK: - Accessible Components

/// An accessible progress indicator
struct AccessibleProgress: View {
    let current: Int
    let total: Int
    let label: String

    var body: some View {
        ProgressView(value: Double(current), total: Double(total))
            .accessibilityLabel(label)
            .accessibilityValue("\(current) of \(total)")
    }
}

/// An accessible stat display
struct AccessibleStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Dynamic Type Support

extension Font {
    /// Scaled font that respects Dynamic Type
    static func scaledTitle() -> Font {
        .title.weight(.bold)
    }

    static func scaledHeadline() -> Font {
        .headline
    }

    static func scaledBody() -> Font {
        .body
    }

    static func scaledCaption() -> Font {
        .caption
    }
}

// MARK: - Reduce Motion Support

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? .none : .default, value: UUID())
    }
}

extension View {
    func respectsReduceMotion() -> some View {
        modifier(ReduceMotionModifier())
    }
}

#Preview {
    VStack(spacing: 20) {
        AccessibleProgress(current: 15, total: 20, label: "Messages used today")

        AccessibleStat(
            icon: "person.3.fill",
            value: "42",
            label: "Total Users",
            color: .blue
        )
    }
    .padding()
}
