import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "6366f1"), Color(hex: "a855f7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Animated Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)

                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 110, height: 110)

                    Text("✨")
                        .font(.system(size: 60))
                        .scaleEffect(isAnimating ? 1 : 0.8)
                }
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                VStack(spacing: 8) {
                    Text("KidsGPT")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)

                    Text("Safe AI Learning Companion")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showContent = true
            }
        }
    }
}

#Preview {
    SplashView()
}
