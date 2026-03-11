import SwiftUI
import Combine

struct SplashView: View {
    @State private var logoScale:   CGFloat = 0.3
    @State private var logoOpacity: Double  = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var ringScale:   CGFloat = 0.5
    @State private var ringOpacity: Double  = 0
    @State private var gridOpacity: Double  = 0
    @State private var dots: [SplashDot]    = []
    
    @StateObject private var store = Store()
    @State private var streams = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(hex: "0A1628").ignoresSafeArea()
                    BlueprintGridView().opacity(gridOpacity).ignoresSafeArea()
                    
                    Image("splash_back")
                        .resizable().scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea().opacity(0.8)
                    
                    // Ambient rings
                    Circle().stroke(Color(hex: "F5B800").opacity(0.10), lineWidth: 55)
                        .frame(width: 300).scaleEffect(ringScale).opacity(ringOpacity)
                    Circle().stroke(Color(hex: "F5B800").opacity(0.05), lineWidth: 30)
                        .frame(width: 380).scaleEffect(ringScale * 0.92).opacity(ringOpacity)
                    
                    // Floating dots
                    ForEach(dots) { d in
                        Circle().fill(Color(hex: "F5B800").opacity(d.opacity))
                            .frame(width: d.size).position(d.pos)
                    }
                    
                    VStack(spacing: 22) {
                        
                        NavigationLink(
                            destination: BuildWebView().navigationBarHidden(true),
                            isActive: $store.state.ui.navigateToWeb
                        ) { EmptyView() }
                        
                        NavigationLink(
                            destination: RootView().navigationBarBackButtonHidden(true),
                            isActive: $store.state.ui.navigateToMain
                        ) { EmptyView() }
                        
                        // Logo
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex: "F5B800"), Color(hex: "E6960A")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 118, height: 118)
                                .shadow(color: Color(hex: "F5B800").opacity(0.55), radius: 28)
                            Text("🏗️").font(.system(size: 54))
                            
                            ProgressView()
                                .tint(.white)
                        }
                        .scaleEffect(logoScale).opacity(logoOpacity)
                        
                        VStack(spacing: 7) {
                            Text("Loading...")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Construction Manager Pro")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.45))
                                .tracking(1.5).textCase(.uppercase)
                        }
                        .offset(y: titleOffset).opacity(titleOpacity)
                    }
                }
                .onAppear {
                    animate()
                    store.dispatch(.initialize)
                    setupStreams()
                }
                .fullScreenCover(isPresented: $store.state.ui.showPermissionPrompt) {
                    BuildNotificationView(store: store)
                }
                .fullScreenCover(isPresented: $store.state.ui.showOfflineView) {
                    UnavailableView()
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private func setupStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { store.dispatch(.trackingReceived($0)) }
            .store(in: &streams)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { store.dispatch(.navigationReceived($0)) }
            .store(in: &streams)
    }

    func animate() {
        withAnimation(.easeIn(duration: 0.7)) { gridOpacity = 0.22 }
        withAnimation(.spring(response: 1.1, dampingFraction: 0.65).delay(0.2)) {
            ringScale = 1.0; ringOpacity = 1.0
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.55).delay(0.35)) {
            logoScale = 1.0; logoOpacity = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6)) {
            titleOffset = 0; titleOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { spawnDots() }
    }

    func spawnDots() {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        dots = (0..<28).map { _ in
            SplashDot(pos: CGPoint(x: .random(in: 0...w), y: .random(in: 0...h)),
                      size: .random(in: 2...6), opacity: .random(in: 0.1...0.55))
        }
    }
}

struct SplashDot: Identifiable {
    let id = UUID()
    var pos: CGPoint; var size: CGFloat; var opacity: Double
}

