import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var animate = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            GlassBackground()
            
            VStack(spacing: 20) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Weather App")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .kerning(4)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                scale = 1.0
                opacity = 1.0
            }
            appViewModel.startSessionCheck()
        }
    }
}

#Preview {
    SplashView().environmentObject(AppViewModel())
}
