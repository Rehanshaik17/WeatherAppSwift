import Foundation
import Combine

class WeatherRepository: ObservableObject {
    static let shared = WeatherRepository()
    
    private let weatherService = WeatherService()
    @Published var weatherData: ForecastWeatherResponse?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cache: [String: ForecastWeatherResponse] = [:]
    
    private init() {
        loadLastKnownWeather()
    }
    
    func getWeather(for query: String) async throws -> ForecastWeatherResponse {
        // Check cache first for fast response
        if let cached = cache[query] {
            self.weatherData = cached
            // Still fetch fresh data in the background
            Task {
                try? await fetchAndCache(for: query)
            }
            return cached
        }
        
        return try await fetchAndCache(for: query)
    }
    
    private func fetchAndCache(for query: String) async throws -> ForecastWeatherResponse {
        print("DEBUG: WeatherRepository fetching for: \(query)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            let freshData = try await weatherService.fetchForecast(for: query, days: 10)
            print("DEBUG: WeatherRepository successfully fetched data for: \(query)")
            cache[query] = freshData
            
            // Update published property on MainActor
            await MainActor.run {
                self.weatherData = freshData
                self.error = nil
            }
            
            // Persist as last known weather
            saveLastKnownWeather(freshData)
            
            return freshData
        } catch {
            print("ERROR: WeatherRepository fetch failed for \(query): \(error.localizedDescription)")
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
    // MARK: - Persistence
    
    private func saveLastKnownWeather(_ data: ForecastWeatherResponse) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "lastKnownWeather")
        }
    }
    
    private func loadLastKnownWeather() {
        if let data = UserDefaults.standard.data(forKey: "lastKnownWeather"),
           let decoded = try? JSONDecoder().decode(ForecastWeatherResponse.self, from: data) {
            self.weatherData = decoded
        }
    }
}
