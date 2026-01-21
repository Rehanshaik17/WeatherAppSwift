import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var viewModel: WeatherViewModel
    @AppStorage("useCelsius") private var useCelsius = true
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // dynamic Header
            headerView
                .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Current Weather
                    currentWeatherSection
                    
                    // Forecast Section
                    forecastSection
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .refreshable {
                await viewModel.requestLocation()
                // Also refresh favorites if needed
                // appViewModel.refreshData()?
            }
        }
        .background(GlassBackground())
        .onAppear {
            print("DEBUG: HomeView appeared, requesting location...")
            viewModel.requestLocation()
        }
        .sheet(isPresented: $showingDetails) {
            if let weather = viewModel.weather {
                WeatherDetailView(weather: weather)
                    .environmentObject(appViewModel)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 4) {
                Text(viewModel.weather?.location.name.uppercased() ?? "WEATHER APP")
                    .font(.headline)
                    .kerning(2)
                if let location = viewModel.weather?.location {
                    Text("\(location.region), \(location.country)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                viewModel.requestLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var currentWeatherSection: some View {
        VStack(spacing: 8) {
            if let current = viewModel.weather?.current {
                Text("\(Int(useCelsius ? current.temp_c : current.temp_f))°")
                    .font(.system(size: 100, weight: .thin))
                
                VStack(spacing: 4) {
                    Text(viewModel.weather?.location.name ?? "")
                        .font(.title2.bold())
                    Text(current.condition.text)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                AsyncImage(url: URL(string: "https:\(current.condition.icon.replacingOccurrences(of: "64x64", with: "128x128"))")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 180, height: 180)
                .shadow(color: .white.opacity(0.5), radius: 20)
                .padding(.top, 20)
                
                // Dynamic details row
                HStack(spacing: 40) {
                    weatherDetailItem(icon: "humidity", value: "\(current.humidity)%", label: "Humidity")
                    weatherDetailItem(icon: "wind", value: "\(Int(current.wind_kph)) km/h", label: "Wind")
                    weatherDetailItem(icon: "uv.index", value: "\(Int(current.uv))", label: "UV Index")
                }
                .padding(.top, 30)
            } else if viewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Fetching Weather...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(spacing: 8) {
                        Text(error.contains("API key") ? "API Configuration Issue" : "Weather Fetch Error")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                    
                    Button {
                        viewModel.requestLocation()
                    } label: {
                        Text("Retry Connection")
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .liquidGlass(cornerRadius: 30)
                .padding()
            }
        }
    }
    
    private func weatherDetailItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("NEXT 10 DAYS")
                    .font(.caption.bold())
                    .kerning(1)
                Spacer()
                Button("DETAILS") {
                    showingDetails = true
                }
                .font(.caption.bold())
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if let days = viewModel.weather?.forecast.forecastday {
                        ForEach(days, id: \.date_epoch) { day in
                            forecastCard(for: day)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func forecastCard(for day: ForecastDay) -> some View {
        VStack(spacing: 12) {
            Text(getDayName(from: day.date))
                .font(.subheadline.bold())
            
            AsyncImage(url: URL(string: "https:\(day.day.condition.icon)")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(.blue)
            }
            .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Text("\(Int(useCelsius ? day.day.maxtemp_c : day.day.maxtemp_f))°")
                    .font(.headline)
                Text("\(Int(useCelsius ? day.day.mintemp_c : day.day.mintemp_f))°")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(width: 90)
        .liquidGlass(cornerRadius: 45)
    }
    
    private func getDayName(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "Mon" }
        
        if Calendar.current.isDateInToday(date) { return "Today" }
        
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct RoundedRect: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView().environmentObject(AppViewModel())
}
