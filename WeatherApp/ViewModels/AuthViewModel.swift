import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoginMode = true
    @Published var shouldNavigateToHome = false
    
    private let supabase = SupabaseService.shared
    
    func authenticate() async {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Capture values on MainActor to avoid crossing actor boundaries inside task group
        let currentIsLoginMode = self.isLoginMode
        let currentPassword = self.password
        let currentConfirmPassword = self.confirmPassword
        let supabaseService = self.supabase
        
        // Validation
        guard !cleanedEmail.isEmpty else {
            errorMessage = "Please enter an email address."
            return
        }
        
        guard cleanedEmail.contains("@") && cleanedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        if !isLoginMode {
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        print("DEBUG: [AuthViewModel] Starting authentication for \(cleanedEmail)...")
        
        do {
            // Use a Task with a timeout to prevent indefinite hangs
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    if currentIsLoginMode {
                        print("DEBUG: [AuthViewModel] Calling supabase.signIn...")
                        try await supabaseService.signIn(email: cleanedEmail, password: currentPassword)
                    } else {
                        print("DEBUG: [AuthViewModel] Calling supabase.signUp...")
                        try await supabaseService.signUp(email: cleanedEmail, password: currentPassword)
                    }
                }
                
                // Add a timeout task
                group.addTask {
                    try await Task.sleep(nanoseconds: 30 * 1_000_000_000) // 30 seconds
                    throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication timed out. Please check your internet connection."])
                }
                
                // Wait for the first task to finish (either success or timeout)
                try await group.next()
                group.cancelAll()
            }
            
            print("DEBUG: [AuthViewModel] Auth success. Transitioning...")
            
            if currentIsLoginMode {
                shouldNavigateToHome = true
            } else {
                // Sign Up successful -> Switch to Login mode
                self.isLoginMode = true
                self.password = ""
                self.confirmPassword = ""
                // Optional: You could show a specialized message here
                // errorMessage = "Account created! Please log in." 
                // But usually switching to login is clear enough or a popup is needed.
                // For now, simple transition.
            }
        } catch {
            print("DEBUG: [AuthViewModel] Auth error: \(error)")
            let desc = error.localizedDescription.lowercased()
            
            if desc.contains("email not confirmed") || desc.contains("yet to confirm") {
                errorMessage = "Login Blocked: Supabase still thinks you need to confirm. \n\n1. Use a TOTALLY NEW email (e.g. test\(Int.random(in: 100...999))@test.com) \n2. OR delete the old user from Supabase Dashboard first."
            } else if desc.contains("invalid login credentials") {
                errorMessage = "Invalid email or password."
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
}

