import Foundation
import Supabase
import Auth

class SupabaseService {
    static let shared = SupabaseService()
    
    private var _client: SupabaseClient?
    
    private init() {
        print("DEBUG: SupabaseService created locally.")
    }
    
    var client: SupabaseClient {
        if let client = _client { return client }
        
        print("DEBUG: Preparing to initialize SupabaseClient...")
        print("DEBUG: URL: \(AppConfig.supabaseURL)")
        
        let client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: .init(
                    autoRefreshToken: true,
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
        
        print("DEBUG: SupabaseClient initialized successfully.")
        _client = client
        return client
    }
    
    func checkConnection() async -> Bool {
        do {
            print("DEBUG: Testing Supabase connection...")
            // Just a simple ping to see if the host resolves and responds
            _ = try await client.auth.session
            print("DEBUG: Supabase connection OK.")
            return true
        } catch {
            print("DEBUG: Supabase connection test failed: \(error)")
            return false
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    var currentUser: User? {
        print("DEBUG: Fetching current user...")
        return _client?.auth.currentUser
    }
    
    // MARK: - Database (Favorites)
    
    struct FavoriteCity: Codable, Identifiable {
        let id: UUID?
        let user_id: UUID?
        let city_name: String
        let created_at: Date?
        
        init(id: UUID? = nil, user_id: UUID? = nil, city_name: String, created_at: Date? = nil) {
            self.id = id
            self.user_id = user_id
            self.city_name = city_name
            self.created_at = created_at
        }
    }
    
    func fetchFavorites() async throws -> [FavoriteCity] {
        guard let userId = currentUser?.id else { return [] }
        
        return try await client.database
            .from("favorite_cities")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
    }
    
    func addFavorite(cityName: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        let favorite = FavoriteCity(user_id: userId, city_name: cityName)
        
        try await client.database
            .from("favorite_cities")
            .insert(favorite)
            .execute()
    }
    
    func removeFavorite(id: UUID) async throws {
        try await client.database
            .from("favorite_cities")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
