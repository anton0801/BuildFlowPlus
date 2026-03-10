import SwiftUI

@main
struct BuildFlowApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
    
}

struct RootView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var dataStore   = DataStore()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            switch authManager.authState {
            case .splash:
                EmptyView()

            case .onboarding:
                OnboardingView()
                    .transition(.opacity)
                    .zIndex(2)

            case .unauthenticated:
                AuthView()
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .top)))
                    .zIndex(1)

            case .guest, .authenticated:
                ContentView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: authManager.authState)
        .onChange(of: authManager.authState) { state in
            if state == .guest || state == .authenticated {
                let uid = authManager.currentUser?.id ?? "local"
                dataStore.configure(userId: uid)
            }
        }
        .preferredColorScheme(.dark)
        .environmentObject(authManager)
        .environmentObject(dataStore)
    }
}


final class AttributionBridge: NSObject {
    var onTracking: (([AnyHashable: Any]) -> Void)?
    var onNavigation: (([AnyHashable: Any]) -> Void)?
    
    private var trackingBuf: [AnyHashable: Any] = [:]
    private var navigationBuf: [AnyHashable: Any] = [:]
    private var timer: Timer?
    
    func receiveTracking(_ data: [AnyHashable: Any]) {
        trackingBuf = data
        scheduleTimer()
        if !navigationBuf.isEmpty { merge() }
    }
    
    func receiveNavigation(_ data: [AnyHashable: Any]) {
        guard !UserDefaults.standard.bool(forKey: "bf_first_launch_flag") else { return }
        navigationBuf = data
        onNavigation?(data)
        timer?.invalidate()
        if !trackingBuf.isEmpty { merge() }
    }
    
    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in self?.merge() }
    }
    
    private func merge() {
        var result = trackingBuf
        navigationBuf.forEach { k, v in
            let key = "deep_\(k)"
            if result[key] == nil { result[key] = v }
        }
        onTracking?(result)
    }
}
