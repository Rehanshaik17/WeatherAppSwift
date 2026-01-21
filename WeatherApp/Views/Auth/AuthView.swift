import SwiftUI
import Supabase
import Auth

struct AuthView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            GlassBackground()
            
            VStack(spacing: 40) {
                // Header
                headerView
                
                // Auth Card
                VStack(spacing: 24) {
                    if let globalError = appViewModel.globalError {
                        VStack(spacing: 8) {
                            Text("Connection Issue")
                                .font(.caption.bold())
                                .foregroundColor(.red)
                            Text(globalError)
                                .font(.system(size: 10))
                                .foregroundColor(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.bottom, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.isLoginMode ? "Sign In" : "Sign Up")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Experience weather through clarity.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 16) {
                        customTextField(title: "Email", placeholder: "name@example.com", text: $viewModel.email)
                        customSecureField(title: "Password", placeholder: "••••••••", text: $viewModel.password)
                        
                        if !viewModel.isLoginMode {
                            customSecureField(title: "Confirm Password", placeholder: "••••••••", text: $viewModel.confirmPassword)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    Button {
                        Task {
                            await viewModel.authenticate()
                            if viewModel.shouldNavigateToHome {
                                print("DEBUG: Login successful, transitioning to main dashboard...")
                                withAnimation(.spring()) {
                                    appViewModel.viewState = .main
                                }
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(viewModel.isLoginMode ? "Login" : "Sign Up")
                        }
                    }
                    .buttonStyle(GlassButtonStyle())
                    
                    if viewModel.isLoginMode {
                        Button("Forgot password?") {
                            // Forgot password action
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(32)
                .liquidGlass(cornerRadius: 44)
                .padding(.horizontal, 24)
                
                // Switch Mode
                Button {
                    withAnimation {
                        viewModel.isLoginMode.toggle()
                    }
                } label: {
                    HStack {
                        Text(viewModel.isLoginMode ? "Don't have an account?" : "Already have an account?")
                        Text(viewModel.isLoginMode ? "Sign Up" : "Login")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .onAppear { print("DEBUG: AuthView onAppear") }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            
            VStack(spacing: 4) {
                Text("Welcome to")
                    .font(.title.bold())
                Text("Weather App")
                    .font(.system(size: 44, weight: .bold))
                Text("IOS 26 • LIQUID EXPERIENCE")
                    .font(.caption2.bold())
                    .foregroundColor(.blue.opacity(0.6))
                    .kerning(1.5)
            }
        }
    }
    
    private func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        }
    }
    
    private func customSecureField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            HStack {
                SecureField(placeholder, text: text)
                    .textContentType(.password)
                Image(systemName: "eye.fill")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

#Preview {
    AuthView().environmentObject(AppViewModel())
}
