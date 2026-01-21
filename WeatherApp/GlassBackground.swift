import SwiftUI

struct GlassBackground: View {
    @State private var animate = false
    @AppStorage("appTheme") private var currentTheme = "Liquid Glass"
    
    var body: some View {
        ZStack {
            baseColor
                .ignoresSafeArea()
            
            LinearGradient(
                colors: gradientColors,
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .blur(radius: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
    
    private var baseColor: Color {
        switch currentTheme {
        case "Dawn": return Color.orange.opacity(0.1)
        case "Night": return Color.black.opacity(0.2)
        default: return Color.blue.opacity(0.1)
        }
    }
    
    private var gradientColors: [Color] {
        switch currentTheme {
        case "Dawn":
            return [.orange.opacity(0.4), .pink.opacity(0.3), .yellow.opacity(0.3), .red.opacity(0.4)]
        case "Night":
            return [.black.opacity(0.4), .blue.opacity(0.2), .indigo.opacity(0.3), .purple.opacity(0.4)]
        default: // Liquid Glass
            return [.blue.opacity(0.4), .purple.opacity(0.3), .cyan.opacity(0.3), .indigo.opacity(0.4)]
        }
    }
}

#Preview {
    GlassBackground()
}
