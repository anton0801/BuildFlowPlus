import SwiftUI

@main
struct BuildFlowApp: App {
    
    @StateObject private var dataStore = DataStore()
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingDone")

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(isFinished: $showSplash)
                        .transition(.opacity)
                } else if showOnboarding {
                    OnboardingView(isFinished: $showOnboarding)
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environmentObject(dataStore)
                        .transition(.opacity)
                        .preferredColorScheme(.dark)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        }
    }
    
}
