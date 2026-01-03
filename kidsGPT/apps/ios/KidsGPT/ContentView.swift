import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedPortal: PortalType? = nil

    var body: some View {
        NavigationStack {
            Group {
                if authManager.isAuthenticated {
                    switch authManager.currentPortal {
                    case .kids:
                        KidsChatView()
                    case .parent:
                        ParentDashboardView()
                    case .admin:
                        AdminPanelView()
                    case .none:
                        LandingView(selectedPortal: $selectedPortal)
                    }
                } else {
                    if let portal = selectedPortal {
                        if portal == .kids {
                            KidsLoginView(onBack: { selectedPortal = nil })
                        } else {
                            LoginView(portalType: portal, onBack: { selectedPortal = nil })
                        }
                    } else {
                        LandingView(selectedPortal: $selectedPortal)
                    }
                }
            }
        }
    }
}

enum PortalType: String, CaseIterable {
    case kids = "kids"
    case parent = "parent"
    case admin = "admin"

    /// Portals visible in the iOS app (excludes admin - admin is web-only)
    static var appVisibleCases: [PortalType] {
        [.kids, .parent]
    }

    var title: String {
        switch self {
        case .kids: return "Kids Zone"
        case .parent: return "Parent Hub"
        case .admin: return "Admin Panel"
        }
    }

    var icon: String {
        switch self {
        case .kids: return "star.fill"
        case .parent: return "heart.fill"
        case .admin: return "shield.fill"
        }
    }

    var emoji: String {
        switch self {
        case .kids: return "🚀"
        case .parent: return "💜"
        case .admin: return "🛡️"
        }
    }

    var subtitle: String {
        switch self {
        case .kids: return "Learn & Play with Sheldon!"
        case .parent: return "Monitor & Manage"
        case .admin: return "System Control"
        }
    }

    var gradient: [Color] {
        switch self {
        case .kids: return [Color(hex: "6366f1"), Color(hex: "a855f7")]
        case .parent: return [Color(hex: "8b5cf6"), Color(hex: "ec4899")]
        case .admin: return [Color(hex: "3b82f6"), Color(hex: "06b6d4")]
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
