import SwiftUI

struct WeatherDetailView: View {
    let weather: ForecastWeatherResponse?
    @AppStorage("useCelsius") private var useCelsius = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            headerView
            
            if let weather = weather {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // Hero Section
                        heroSection(for: weather)
                        
                        // Grid of details
                        detailGrid(for: weather)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView("Loading Weather Details...")
                    Spacer()
                }
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
            
            Text("Weather Details")
                .font(.title3.bold())
            
            Spacer()
            
            Button {
                // Share action
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 20)
    }
    
    private func heroSection(for weather: ForecastWeatherResponse) -> some View {
        VStack(spacing: 12) {
            Text(weather.location.name)
                .font(.largeTitle.bold())
            
            AsyncImage(url: URL(string: "https:\(weather.current.condition.icon.replacingOccurrences(of: "64x64", with: "128x128"))")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 150, height: 150)
            
            Text(weather.current.condition.text)
                .font(.title3)
                .foregroundColor(.secondary)
            
            HStack(alignment: .top, spacing: 0) {
                Text("\(Int(useCelsius ? weather.current.temp_c : weather.current.temp_f))")
                    .font(.system(size: 80, weight: .thin))
                Text("°")
                    .font(.system(size: 40, weight: .light))
                    .padding(.top, 10)
            }
        }
    }
    
    private func detailGrid(for weather: ForecastWeatherResponse) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            detailCard(icon: "humidity.fill", title: "HUMIDITY", value: "\(weather.current.humidity)%")
            detailCard(icon: "wind", title: "WIND SPEED", value: "\(Int(useCelsius ? weather.current.wind_kph : weather.current.wind_mph)) \(useCelsius ? "km/h" : "mph")")
            detailCard(icon: "thermometer", title: "FEELS LIKE", value: "\(Int(useCelsius ? weather.current.feelslike_c : weather.current.feelslike_f))°")
            detailCard(icon: "eye.fill", title: "VISIBILITY", value: "\(Int(useCelsius ? weather.current.vis_km : weather.current.vis_miles)) \(useCelsius ? "km" : "mi")")
            detailCard(icon: "sun.max.fill", title: "UV INDEX", value: "\(Int(weather.current.uv))")
            detailCard(icon: "gauge.with.dots.needle.bottom.100percent", title: "PRESSURE", value: "\(Int(weather.current.pressure_mb)) hPa")
            detailCard(icon: "cloud.fill", title: "CLOUD COVER", value: "\(weather.current.cloud)%")
            detailCard(icon: "drop.fill", title: "PRECIPITATION", value: "\(weather.current.precip_mm) mm")
        }
    }
    
    private func detailCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2.bold())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 24)
    }
}

#Preview {
    WeatherDetailView(weather: nil).environmentObject(AppViewModel())
}
