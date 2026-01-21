import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(weatherViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView(selectedTab: $selectedTab)
                .environmentObject(weatherViewModel)
                .environmentObject(appViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            SettingsView()
                .environmentObject(appViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
        // Professional transparent tab bar
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView().environmentObject(AppViewModel())
}
