import Foundation

enum AppConfig {
    // IMPORTANT: Replace this URL with your correct Supabase Project URL
    static let supabaseURL: URL = {
        let urlString = "https://psjmujlwhqpnihvszgqr.supabase.co"
        if let url = URL(string: urlString) {
            return url
        }
        return URL(string: "http://localhost") ?? URL(fileURLWithPath: "/")
    }()
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzam11amx3aHFwbmlodnN6Z3FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4OTA4MDQsImV4cCI6MjA4NDQ2NjgwNH0.BK5hVRvmy5pXH-rxOQhBEcPtf-FlcsN_S4EyEWSChC0"
    static let weatherAPIKey = "387eef6543d04b8fbd162743262101"
}
