import SwiftUI
import Supabase
import Auth

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("useCelsius") private var useCelsius = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("locationServicesEnabled") private var locationServicesEnabled = true
    @AppStorage("backgroundRefreshEnabled") private var backgroundRefreshEnabled = false
    @AppStorage("appTheme") private var currentTheme = "Liquid Glass"
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Profile Card
                    profileCard
                    
                    // Units
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UNITS")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .kerning(1)
                        
                        HStack(spacing: 0) {
                            unitButton(title: "Celsius (°C)", isSelected: useCelsius) { useCelsius = true }
                            unitButton(title: "Fahrenheit (°F)", isSelected: !useCelsius) { useCelsius = false }
                        }
                        .padding(4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    
                    // Preferences
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PREFERENCES")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .kerning(1)
                        
                        VStack(spacing: 0) {
                            toggleRow(icon: "bell.fill", color: .blue, title: "Notifications", subtitle: "Severe weather alerts", isOn: $notificationsEnabled)
                            Divider().padding(.leading, 56)
                            toggleRow(icon: "location.fill", color: .blue, title: "Location Services", subtitle: "Precision tracking", isOn: $locationServicesEnabled)
                            Divider().padding(.leading, 56)
                            toggleRow(icon: "arrow.clockwise", color: .blue, title: "Background Refresh", subtitle: "", isOn: $backgroundRefreshEnabled)
                        }
                        .liquidGlass(cornerRadius: 24)
                    }
                    
                    // Appearance & Help
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APPEARANCE")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .kerning(1)
                        
                        HStack(spacing: 16) {
                            Image(systemName: "paintpalette.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .cornerRadius(12)
                            
                            Text("Theme")
                                .font(.subheadline.bold())
                            
                            Spacer()
                            
                            Menu {
                                Picker("Theme", selection: $currentTheme) {
                                    Text("Liquid Glass").tag("Liquid Glass")
                                    Text("Dawn").tag("Dawn")
                                    Text("Night").tag("Night")
                                }
                            } label: {
                                HStack {
                                    Text(currentTheme)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 24)
                        navigationRow(icon: "questionmark.circle.fill", color: .blue, title: "Help & Support", isExternal: true)
                    }
                    
                    // Sign Out
                    Button {
                        appViewModel.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.top, 20)
                    
                    // Footer
                    footerView
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 24)
        .background(GlassBackground())
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Settings")
                .font(.title3.bold())
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.top, 20)
    }
    
    private var profileCard: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary.opacity(0.3))
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(SupabaseService.shared.currentUser?.email ?? "User Profile")
                    .font(.headline)
                Text("Glasscast Premium")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 24)
    }
    
    private func unitButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.medium())
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.white : Color.clear)
                .foregroundColor(isSelected ? .black : .secondary)
                .cornerRadius(12)
                .shadow(color: isSelected ? .black.opacity(0.05) : .clear, radius: 5)
        }
    }
    
    private func toggleRow(icon: String, color: Color, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(16)
    }
    
    private func navigationRow(icon: String, color: Color, title: String, value: String = "", isExternal: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(12)
            
            Text(title)
                .font(.subheadline.bold())
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: isExternal ? "arrow.up.right" : "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 24)
    }
    
    private var footerView: some View {
        VStack(spacing: 8) {
            Text("GLASSCAST v26.4.1")
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Text("PRIVACY POLICY")
                Circle().frame(width: 3, height: 3)
                Text("TERMS OF SERVICE")
            }
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.top, 40)
    }
}

#Preview {
    SettingsView().environmentObject(AppViewModel())
}
