import Foundation
import Network
import SwiftUI

/// Monitors network connectivity and provides real-time status updates
@MainActor
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied

                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.connectionType = .ethernet
                } else {
                    self?.connectionType = .unknown
                }
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    deinit {
        monitor.cancel()
    }
}

// MARK: - Network Status Banner
struct NetworkStatusBanner: View {
    @ObservedObject var networkMonitor: NetworkMonitor

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.body)

                VStack(alignment: .leading, spacing: 2) {
                    Text("No Internet Connection")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Please check your connection")
                        .font(.caption)
                        .opacity(0.8)
                }

                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red.opacity(0.9))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - View Modifier for Network Awareness
struct NetworkAwareModifier: ViewModifier {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showOfflineAlert = false

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            NetworkStatusBanner(networkMonitor: networkMonitor)
                .animation(.easeInOut, value: networkMonitor.isConnected)

            content
                .environmentObject(networkMonitor)
        }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            if !isConnected {
                // Haptic feedback when going offline
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
}

extension View {
    func networkAware() -> some View {
        modifier(NetworkAwareModifier())
    }
}

// MARK: - Offline Placeholder View
struct OfflinePlaceholderView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 44))
                    .foregroundColor(.red)
            }

            VStack(spacing: 8) {
                Text("You're Offline")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text("Please check your internet connection and try again.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.kidsGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(32)
    }
}

#Preview {
    VStack {
        NetworkStatusBanner(networkMonitor: NetworkMonitor())
        Spacer()
        OfflinePlaceholderView(onRetry: {})
        Spacer()
    }
}
