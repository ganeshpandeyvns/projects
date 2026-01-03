import SwiftUI

struct LoginView: View {
    let portalType: PortalType
    let onBack: () -> Void

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient

    @State private var email = ""
    @State private var name = ""
    @State private var isNewUser = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 24) {
                Spacer()

                // Portal Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: portalType.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: portalType.gradient.first!.opacity(0.4), radius: 15, x: 0, y: 8)

                    Text(portalType.emoji)
                        .font(.system(size: 40))
                }

                // Title
                VStack(spacing: 8) {
                    Text(portalType.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(isNewUser ? "Create your account" : "Welcome back!")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                // Form
                VStack(spacing: 16) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)

                        TextField("you@example.com", text: $email)
                            .textFieldStyle(PremiumTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }

                    // Name Field (for new users)
                    if isNewUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textSecondary)

                            TextField(portalType == .admin ? "Admin Name" : "Your name", text: $name)
                                .textFieldStyle(PremiumTextFieldStyle())
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(10)
                            .transition(.opacity)
                    }

                    // Submit Button
                    Button(action: handleSubmit) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isNewUser ? "Create Account" : "Continue")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: portalType.gradient, startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: portalType.gradient.first!.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 24)

                // Toggle login/register
                Button(action: {
                    withAnimation(.smooth) {
                        isNewUser.toggle()
                        showError = false
                    }
                }) {
                    if isNewUser {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(AppColors.textSecondary)
                            Text("Sign in")
                                .fontWeight(.semibold)
                                .foregroundColor(portalType.gradient.first!)
                        }
                    } else {
                        HStack {
                            Text("New here?")
                                .foregroundColor(AppColors.textSecondary)
                            Text("Create account")
                                .fontWeight(.semibold)
                                .foregroundColor(portalType.gradient.first!)
                        }
                    }
                }
                .font(.subheadline)

                // Back Button
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back to portal selection")
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .font(.subheadline)
                }
                .padding(.top, 8)

                Spacer()
            }
        }
    }

    private func handleSubmit() {
        guard !email.isEmpty else { return }

        isLoading = true
        showError = false

        Task {
            do {
                if isNewUser {
                    if portalType == .admin {
                        let user = try await apiClient.createAdmin(email: email, displayName: name.isEmpty ? "Admin" : name)
                        await MainActor.run {
                            authManager.login(user: user, portal: .admin)
                        }
                    } else {
                        let user = try await apiClient.register(email: email, displayName: name.isEmpty ? nil : name)
                        await MainActor.run {
                            authManager.login(user: user, portal: .parent)
                        }
                    }
                } else {
                    let user = try await apiClient.login(email: email)

                    // Check admin access
                    if portalType == .admin && !user.isAdmin {
                        await MainActor.run {
                            errorMessage = "This account doesn't have admin access."
                            showError = true
                            isLoading = false
                        }
                        return
                    }

                    await MainActor.run {
                        authManager.login(user: user, portal: portalType)
                    }
                }
            } catch let error as APIError {
                await MainActor.run {
                    if case .httpError(let statusCode) = error, statusCode == 404 {
                        // User not found - show registration
                        isNewUser = true
                        showError = false
                    } else if case .httpError(let statusCode) = error, statusCode == 400 {
                        // Admin already exists
                        errorMessage = "An admin already exists. Please login."
                        showError = true
                        isNewUser = false
                    } else {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Connection failed. Please try again."
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Premium Text Field Style
struct PremiumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color(hex: "f8fafc"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "e2e8f0"), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView(portalType: .parent, onBack: {})
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
