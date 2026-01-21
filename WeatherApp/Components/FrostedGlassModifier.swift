import SwiftUI

struct FrostedGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.4
    
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial.opacity(opacity))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func frostedGlass(cornerRadius: CGFloat = 20, opacity: Double = 0.4) -> some View {
        self.modifier(FrostedGlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 30
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 30) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}
