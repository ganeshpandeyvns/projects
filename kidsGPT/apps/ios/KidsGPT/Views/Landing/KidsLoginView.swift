import SwiftUI

struct KidsLoginView: View {
    let onBack: () -> Void

    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var apiClient: APIClient

    @State private var pin = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false

    @FocusState private var isPinFocused: Bool

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 24) {
                Spacer()

                // Fun Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "f59e0b"), Color(hex: "ea580c")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: "f59e0b").opacity(0.4), radius: 20, x: 0, y: 10)

                    Text("⚡")
                        .font(.system(size: 50))
                }

                // Title
                VStack(spacing: 8) {
                    Text("Hey there, friend!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Enter your secret PIN to start")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                // PIN Entry Card
                VStack(spacing: 20) {
                    Text("Your 6-Digit PIN")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)

                    // PIN Input
                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            PinDigitBox(
                                digit: index < pin.count ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : "",
                                isActive: index == pin.count
                            )
                        }
                    }
                    .onTapGesture {
                        isPinFocused = true
                    }

                    // Hidden text field for keyboard input
                    TextField("", text: $pin)
                        .keyboardType(.numberPad)
                        .focused($isPinFocused)
                        .frame(width: 0, height: 0)
                        .opacity(0)
                        .onChange(of: pin) { _, newValue in
                            // Only allow digits and max 6 characters
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 6 {
                                pin = filtered
                            } else {
                                pin = String(filtered.prefix(6))
                            }
                        }

                    Text("Ask your parent for your PIN!")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))

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

                    // Login Button
                    Button(action: handleLogin) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Let's Go! 🚀")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "f59e0b"), Color(hex: "ea580c")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color(hex: "f59e0b").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || pin.count != 6)
                    .opacity(pin.count != 6 ? 0.6 : 1)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 24)

                // Help text
                VStack(spacing: 4) {
                    Text("Don't have a PIN yet?")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))

                    Text("Ask your parent to add you in Parent Hub!")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 8)

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
        .onAppear {
            isPinFocused = true
        }
    }

    private func handleLogin() {
        guard pin.count == 6 else { return }

        isLoading = true
        showError = false

        Task {
            do {
                let response = try await apiClient.kidLogin(pin: pin)
                await MainActor.run {
                    authManager.kidLogin(childId: response.childId, childName: response.childName)
                }
            } catch let error as APIError {
                await MainActor.run {
                    if case .httpError(let statusCode) = error, statusCode == 404 {
                        errorMessage = "Invalid PIN. Please check with your parent."
                    } else if case .httpError(let statusCode) = error, statusCode == 403 {
                        errorMessage = "This account is not active. Please ask your parent."
                    } else {
                        errorMessage = "Something went wrong. Please try again."
                    }
                    showError = true
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

// MARK: - PIN Digit Box
struct PinDigitBox: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "f8fafc"))
                .frame(width: 45, height: 55)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isActive ? Color(hex: "f59e0b") : Color(hex: "e2e8f0"),
                            lineWidth: isActive ? 2 : 1
                        )
                )

            if digit.isEmpty {
                Circle()
                    .fill(Color(hex: "cbd5e1"))
                    .frame(width: 12, height: 12)
            } else {
                Text(digit)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

#Preview {
    KidsLoginView(onBack: {})
        .environmentObject(AuthManager())
        .environmentObject(APIClient())
}
