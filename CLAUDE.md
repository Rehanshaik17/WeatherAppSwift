# Glasscast (WeatherApp) AI Context

## Project Overview
Glasscast is a minimal, premium weather application built with SwiftUI, adhering to the "Liquid Glass" design aesthetic. It uses WeatherAPI.com for data and Supabase for authentication and data persistence.

## Architecture
- **Pattern**: MVVM (Model-View-ViewModel) with Repository pattern.
- **Dependency Injection**: dependency injection via `@EnvironmentObject` and Singleton Repositories (`WeatherRepository`, `SupabaseService`).
- **Concurrency**: Swift Concurrency (`async/await`, `Task`, `@MainActor`).

## Technology Stack
- **Languages**: Swift 5.9+
- **Frameworks**: SwiftUI, Combine
- **Backend**: Supabase (Auth, Postgres)
- **Networking**: URLSession, Codable

## Design System
- **Theme**: Liquid Glass (Blur, Translucency, Gradients).
- **Colors**: Dynamic themes (Liquid Glass, Dawn, Night).
- **Components**: `GlassBackground`, `GlassButton`, custom modifiers.
- **Typography**: System fonts with dynamic scaling.

## Code Standards
- **Imports**: Frameworks first, then modules.
- **Naming**: CamelCase for Swift, snake_case for Supabase tables/JSON.
- **Error Handling**: Use `do-catch` blocks and user-friendly error messages (decoded from API).
- **Secrets**: Store sensitive keys in `Secrets.xcconfig` and `Info.plist` (avoid hardcoding).
- **Safety**: Robust optional unwrapping, main thread UI updates.

## Supabase Schema
### Table: `favorite_cities`
- `id`: UUID (Primary Key)
- `user_id`: UUID (Foreign Key to auth.users)
- `city_name`: Text
- `created_at`: Timestamptz
