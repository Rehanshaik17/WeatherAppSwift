import Foundation
import Combine
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: ForecastWeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentCity = "London"
    
    private let repository = WeatherRepository.shared
    private let supabase = SupabaseService.shared
    @Published var locationService = LocationService()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("DEBUG: WeatherViewModel initialized.")
        setupLocationTracking()
        setupRepositoryBinding()
    }
    
    private func setupRepositoryBinding() {
        repository.$weatherData
            .assign(to: &$weather)
        
        repository.$isLoading
            .assign(to: &$isLoading)
            
        repository.$error
            .map { $0?.localizedDescription }
            .assign(to: &$errorMessage)
    }
    
    private func setupLocationTracking() {
        locationService.$location
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                Task {
                    if UserDefaults.standard.bool(forKey: "locationServicesEnabled") {
                        await self?.fetchWeatherForLocation(lat: coordinate.latitude, lon: coordinate.longitude)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        if UserDefaults.standard.bool(forKey: "locationServicesEnabled") {
            locationService.requestLocation()
        }
    }
    
    func fetchWeatherData(for city: String) async {
        do {
            let result = try await repository.getWeather(for: city)
            self.currentCity = result.location.name
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchWeatherForLocation(lat: Double, lon: Double) async {
        do {
            let query = "\(lat),\(lon)"
            let result = try await repository.getWeather(for: query)
            self.currentCity = result.location.name
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Favorites
    
    func toggleFavorite() async {
        guard let cityName = weather?.location.name else { return }
        
        do {
            let favorites = try await supabase.fetchFavorites()
            if let existing = favorites.first(where: { $0.city_name == cityName }) {
                if let id = existing.id {
                    try await supabase.removeFavorite(id: id)
                }
            } else {
                try await supabase.addFavorite(cityName: cityName)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
