import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Home",      systemImage: "house.fill") }.tag(0)
            StagesView()
                .tabItem { Label("Stages",    systemImage: "list.number") }.tag(1)
            MaterialsView()
                .tabItem { Label("Materials", systemImage: "shippingbox.fill") }.tag(2)
            CalculatorView()
                .tabItem { Label("Calc",      systemImage: "function") }.tag(3)
            BudgetView()
                .tabItem { Label("Budget",    systemImage: "banknote.fill") }.tag(4)
            WorkersView()
                .tabItem { Label("Crew",      systemImage: "person.2.fill") }.tag(5)
        }
        .accentColor(Color(hex: "F5B800"))
        .onAppear { configureTabBar() }
    }

    func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "0D1F3C"))
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
