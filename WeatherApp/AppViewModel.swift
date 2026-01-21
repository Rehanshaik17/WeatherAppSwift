import Foundation
import Combine
import Supabase
import SwiftUI

enum ViewState {
    case splash
    case auth
    case main
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var viewState: ViewState = .splash
    @Published var globalError: String?
    private let supabase = SupabaseService.shared
    
    init() {
        // Init with splash, don't trigger check in background here
        print("DEBUG: AppViewModel initialized.")
    }
    
    func startSessionCheck() {
        print("DEBUG: AppViewModel starting session check sequence...")
        Task {
            do {
                // Give the splash screen a moment to stay visible
                try await Task.sleep(nanoseconds: 2 * 1000_000_000)
                
                print("DEBUG: Checking Supabase session...")
                let _ = try await supabase.checkConnection()
                
                if SupabaseService.shared.currentUser != nil {
                    print("DEBUG: Active session found. Transitioning to main.")
                    withAnimation { self.viewState = ViewState.main }
                } else {
                    print("DEBUG: No session. Transitioning to auth.")
                    withAnimation { self.viewState = ViewState.auth }
                }
            } catch {
                print("DEBUG: CRITICAL ERROR IN SESSION CHECK: \(error)")
                self.globalError = "Startup Error: \(error.localizedDescription)\n\nPlease check your Supabase URL & Key in AppConfig.swift"
                withAnimation { viewState = .auth }
            }
        }
    }
    
    func signOut() {
        Task {
            try? await supabase.signOut()
            viewState = .auth
        }
    }
}
