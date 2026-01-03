import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var selectedChild: ChildWithStats? = nil
    @Published var currentPortal: PortalType? = nil
    @Published var isAuthenticated = false
    @Published var kidChildId: Int? = nil  // For kids who login with PIN
    @Published var kidChildName: String? = nil

    private let userDefaultsKey = "kidsgpt_current_user"
    private let childDefaultsKey = "kidsgpt_selected_child"
    private let portalDefaultsKey = "kidsgpt_current_portal"
    private let kidChildIdKey = "kidsgpt_kid_child_id"
    private let kidChildNameKey = "kidsgpt_kid_child_name"

    init() {
        loadSavedState()
    }

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
        self.currentUser = nil
        self.selectedChild = nil
        self.currentPortal = nil
        self.isAuthenticated = false
        self.kidChildId = nil
        self.kidChildName = nil
        clearSavedState()
    }

    func switchPortal(to portal: PortalType) {
        self.currentPortal = portal
        saveState()
    }

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
}
