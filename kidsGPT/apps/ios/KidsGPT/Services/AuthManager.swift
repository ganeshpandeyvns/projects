import Foundation
import SwiftUI

// Import Firebase when available
// import FirebaseAuth

// MARK: - Firebase Configuration
struct FirebaseConfig {
    // Set to true when Firebase SDK is added and configured
    static let isFirebaseEnabled = false
}

// MARK: - Firebase Auth Error Types
enum FirebaseAuthError: Error {
    case notConfigured
    case signInFailed
    case signUpFailed
    case invalidCredentials
    case weakPassword
    case emailAlreadyInUse
    case userNotFound

    var localizedDescription: String {
        switch self {
        case .notConfigured:
            return "Firebase is not configured"
        case .signInFailed:
            return "Sign in failed"
        case .signUpFailed:
            return "Sign up failed"
        case .invalidCredentials:
            return "Invalid email or password"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "Email is already registered"
        case .userNotFound:
            return "No account found with this email"
        }
    }
}

class AuthManager: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var selectedChild: ChildWithStats? = nil
    @Published var currentPortal: PortalType? = nil
    @Published var isAuthenticated = false
    @Published var kidChildId: Int? = nil  // For kids who login with PIN
    @Published var kidChildName: String? = nil
    @Published var isLoading = false

    // Firebase user ID token for API requests
    @Published var firebaseIdToken: String? = nil

    private let userDefaultsKey = "kidsgpt_current_user"
    private let childDefaultsKey = "kidsgpt_selected_child"
    private let portalDefaultsKey = "kidsgpt_current_portal"
    private let kidChildIdKey = "kidsgpt_kid_child_id"
    private let kidChildNameKey = "kidsgpt_kid_child_name"

    var isFirebaseEnabled: Bool {
        FirebaseConfig.isFirebaseEnabled
    }

    init() {
        loadSavedState()
    }

    // MARK: - Firebase Auth Methods

    /// Sign in with email and password using Firebase
    func firebaseSignIn(email: String, password: String) async throws -> String {
        guard isFirebaseEnabled else {
            throw FirebaseAuthError.notConfigured
        }

        // When Firebase SDK is added, uncomment this:
        /*
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let token = try await result.user.getIDToken()
            await MainActor.run {
                self.firebaseIdToken = token
            }
            return token
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
        */

        throw FirebaseAuthError.notConfigured
    }

    /// Create account with email and password using Firebase
    func firebaseSignUp(email: String, password: String, displayName: String?) async throws -> String {
        guard isFirebaseEnabled else {
            throw FirebaseAuthError.notConfigured
        }

        // When Firebase SDK is added, uncomment this:
        /*
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            // Update display name if provided
            if let name = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = name
                try await changeRequest.commitChanges()
            }

            let token = try await result.user.getIDToken()
            await MainActor.run {
                self.firebaseIdToken = token
            }
            return token
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
        */

        throw FirebaseAuthError.notConfigured
    }

    /// Sign out from Firebase
    func firebaseSignOut() throws {
        guard isFirebaseEnabled else { return }

        // When Firebase SDK is added, uncomment this:
        // try Auth.auth().signOut()

        firebaseIdToken = nil
    }

    /// Refresh the Firebase ID token
    func refreshFirebaseToken() async throws -> String? {
        guard isFirebaseEnabled else { return nil }

        // When Firebase SDK is added, uncomment this:
        /*
        guard let user = Auth.auth().currentUser else { return nil }
        let token = try await user.getIDToken(forcingRefresh: true)
        await MainActor.run {
            self.firebaseIdToken = token
        }
        return token
        */

        return nil
    }

    // MARK: - Legacy Auth Methods (MVP fallback)

    func login(user: User, portal: PortalType) {
        self.currentUser = user
        self.currentPortal = portal
        self.isAuthenticated = true
        saveState()
    }

    func kidLogin(childId: Int, childName: String) {
        self.kidChildId = childId
        self.kidChildName = childName
        self.currentPortal = .kids
        self.isAuthenticated = true
        saveState()
    }

    func selectChild(_ child: ChildWithStats) {
        self.selectedChild = child
        saveState()
    }

    func logout() {
        // Sign out from Firebase if enabled
        if isFirebaseEnabled {
            try? firebaseSignOut()
        }

        self.currentUser = nil
        self.selectedChild = nil
        self.currentPortal = nil
        self.isAuthenticated = false
        self.kidChildId = nil
        self.kidChildName = nil
        self.firebaseIdToken = nil
        clearSavedState()
    }

    func switchPortal(to portal: PortalType) {
        self.currentPortal = portal
        saveState()
    }

    // MARK: - State Persistence

    private func saveState() {
        if let user = currentUser, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
        if let child = selectedChild, let data = try? JSONEncoder().encode(child) {
            UserDefaults.standard.set(data, forKey: childDefaultsKey)
        }
        if let portal = currentPortal {
            UserDefaults.standard.set(portal.rawValue, forKey: portalDefaultsKey)
        }
        if let kidId = kidChildId {
            UserDefaults.standard.set(kidId, forKey: kidChildIdKey)
        }
        if let kidName = kidChildName {
            UserDefaults.standard.set(kidName, forKey: kidChildNameKey)
        }
    }

    private func loadSavedState() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
        if let childData = UserDefaults.standard.data(forKey: childDefaultsKey),
           let child = try? JSONDecoder().decode(ChildWithStats.self, from: childData) {
            self.selectedChild = child
        }
        if let portalString = UserDefaults.standard.string(forKey: portalDefaultsKey),
           let portal = PortalType(rawValue: portalString) {
            self.currentPortal = portal
        }
        // Load kid login state
        let kidId = UserDefaults.standard.integer(forKey: kidChildIdKey)
        if kidId > 0 {
            self.kidChildId = kidId
            self.kidChildName = UserDefaults.standard.string(forKey: kidChildNameKey)
            self.isAuthenticated = true
        }
    }

    private func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: childDefaultsKey)
        UserDefaults.standard.removeObject(forKey: portalDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kidChildIdKey)
        UserDefaults.standard.removeObject(forKey: kidChildNameKey)
    }

    // MARK: - Firebase Error Mapping

    private func mapFirebaseError(_ error: NSError) -> FirebaseAuthError {
        // Map Firebase Auth error codes to our error type
        switch error.code {
        case 17008: // Invalid email
            return .invalidCredentials
        case 17009: // Wrong password
            return .invalidCredentials
        case 17011: // User not found
            return .userNotFound
        case 17026: // Weak password
            return .weakPassword
        case 17007: // Email already in use
            return .emailAlreadyInUse
        default:
            return .signInFailed
        }
    }
}
