import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject private var appViewModel = AppViewModel()

    init() {
        print("DEBUG: WeatherApp initializing...")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch appViewModel.viewState {
                case .splash:
                    SplashView()
                case .auth:
                    AuthView()
                case .main:
                    RootTabView()
                }
            }
            .animation(.easeInOut, value: appViewModel.viewState)
            .environmentObject(appViewModel)
        }
    }
}

