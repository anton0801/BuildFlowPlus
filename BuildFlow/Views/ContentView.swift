import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataStore:   DataStore
    @State private var selectedTab  = 0
    @State private var showProfile  = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Home",      systemImage: "house.fill") }.tag(0)
                StagesView()
                    .tabItem { Label("Stages",    systemImage: "list.number") }.tag(1)
                MaterialsView()
                    .tabItem { Label("Materials", systemImage: "shippingbox.fill") }.tag(2)
                CalculatorView()
                    .tabItem { Label("Calc",      systemImage: "function") }.tag(3)
//                BudgetView()
//                    .tabItem { Label("Budget",    systemImage: "banknote.fill") }.tag(4)
                WorkersView()
                    .tabItem { Label("Crew",      systemImage: "person.2.fill") }.tag(5)
            }
            .accentColor(Color(hex: "F5B800"))
            .onAppear { configureTabBar() }
        }
        .overlay(alignment: .topTrailing) {
            // Profile button — always accessible
            Button { showProfile = true } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "0D1F3C"))
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.3), radius: 6)
                    Text(authManager.currentUser?.avatarEmoji ?? "👤")
                        .font(.system(size: 18))
                    if authManager.authState == .guest {
                        Circle().fill(Color(hex: "FF9500")).frame(width: 10, height: 10)
                            .offset(x: 13, y: -13)
                    }
                }
            }
            .padding(.top, 54).padding(.trailing, 16)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authManager)
                .environmentObject(dataStore)
        }
    }

    func configureTabBar() {
        let a = UITabBarAppearance()
        a.configureWithOpaqueBackground()
        a.backgroundColor = UIColor(Color(hex: "0D1F3C"))
        UITabBar.appearance().standardAppearance = a
        if #available(iOS 15, *) { UITabBar.appearance().scrollEdgeAppearance = a }
    }
}


struct UnavailableView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("wifi_screen_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                Image("wifi_screen_alert")
                    .resizable()
                    .frame(width: 200, height: 180)
            }
        }
        .ignoresSafeArea()
    }
}
