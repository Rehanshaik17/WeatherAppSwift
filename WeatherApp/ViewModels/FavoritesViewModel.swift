import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [SupabaseService.FavoriteCity] = []
    @Published var searchQuery = "" {
        didSet {
            if searchQuery.isEmpty {
                searchResults = []
            } else if searchQuery.count >= 3 || searchQuery == " " {
                Task {
                    if searchQuery == " " {
                        // "View All" mode - just show suggestions as results but maybe more
                        searchResults = suggestedCities.map { city in
                            WeatherLocation(name: city, region: "Global", country: "World", lat: 0, lon: 0, tz_id: "", localtime_epoch: 0, localtime: "")
                        }
                    } else {
                        await performSearch()
                    }
                }
            }
        }
    }
    @Published var searchResults: [WeatherLocation] = []
    @Published var suggestedCities = ["Dubai", "New York", "London", "Tokyo", "Singapore", "Sydney"]
    @Published var recentSearches: [String] = [] {
        didSet {
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    private let weatherService = WeatherService()
    
    init() {
        self.recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }
    
    func fetchFavorites() async {
        isLoading = true
        do {
            self.favorites = try await supabase.fetchFavorites()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func performSearch() async {
        guard searchQuery.count >= 3 else { return }
        isLoading = true
        do {
            // WeatherAPI.com 'current.json' or 'search.json' can be used. 
            // We'll use forecast because it gives more data, or just a simple fetch.
            let result = try await weatherService.fetchWeather(for: searchQuery)
            self.searchResults = [result.location]
        } catch {
            print("DEBUG: Search error: \(error)")
        }
        isLoading = false
    }
    
    func addFavorite(city: String) async {
        do {
            try await supabase.addFavorite(cityName: city)
            await fetchFavorites()
            
            // Add to recent searches if not already present
            await MainActor.run {
                if !recentSearches.contains(city) {
                    recentSearches.insert(city, at: 0)
                    if recentSearches.count > 5 {
                        recentSearches.removeLast()
                    }
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func removeFavorite(id: UUID) async {
        do {
            try await supabase.removeFavorite(id: id)
            await fetchFavorites()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
    }
}
