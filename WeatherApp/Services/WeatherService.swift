import Foundation

struct WeatherAPIErrorResponse: Codable {
    struct ErrorDetail: Codable {
        let code: Int
        let message: String
    }
    let error: ErrorDetail
}

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case serverError(String? = nil)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .serverError(let message): return message ?? "Weather server returned an error"
        case .decodingError: return "Failed to process weather data"
        }
    }
}

struct WeatherService {
    private let apiKey = AppConfig.weatherAPIKey
    private let baseURL = "https://api.weatherapi.com/v1"

    func fetchWeather(for query: String) async throws -> QuickWeatherResponse {
        let urlString = "\(baseURL)/current.json?key=\(apiKey)&q=\(query)&aqi=no"
        print("DEBUG: Fetching weather from URL: \(urlString)")
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("ERROR: Invalid URL for query: \(query)")
            throw WeatherError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("ERROR: Not an HTTP response")
            throw WeatherError.serverError()
        }
        
        print("DEBUG: Weather API Response Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if let apiError = try? JSONDecoder().decode(WeatherAPIErrorResponse.self, from: data) {
                print("ERROR: Weather API Error: \(apiError.error.message) (code: \(apiError.error.code))")
                throw WeatherError.serverError(apiError.error.message)
            }
            if let errorJson = try? JSONSerialization.jsonObject(with: data) {
                print("ERROR: Weather API Error Body: \(errorJson)")
            }
            throw WeatherError.serverError(nil)
        }

        do {
            return try JSONDecoder().decode(QuickWeatherResponse.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            print("ERROR: Decoding failed - Key '\(key.stringValue)' not found in: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("ERROR: Decoding failed - Type '\(type)' mismatch: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("ERROR: Decoding failed - Value of type '\(type)' not found: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch {
            print("ERROR: Decoding failed with unknown error: \(error)")
            throw WeatherError.decodingError
        }
    }

    func fetchForecast(for query: String, days: Int = 5) async throws -> ForecastWeatherResponse {
        let urlString = "\(baseURL)/forecast.json?key=\(apiKey)&q=\(query)&days=\(days)&aqi=no&alerts=no"
        print("DEBUG: Fetching forecast from URL: \(urlString)")
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("ERROR: Invalid URL for forecast query: \(query)")
            throw WeatherError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("ERROR: Not an HTTP response (forecast)")
            throw WeatherError.serverError()
        }
        
        print("DEBUG: Forecast API Response Code: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            if let apiError = try? JSONDecoder().decode(WeatherAPIErrorResponse.self, from: data) {
                print("ERROR: Forecast API Error: \(apiError.error.message) (code: \(apiError.error.code))")
                throw WeatherError.serverError(apiError.error.message)
            }
            if let errorJson = try? JSONSerialization.jsonObject(with: data) {
                print("ERROR: Forecast API Error Body: \(errorJson)")
            }
            throw WeatherError.serverError(nil)
        }

        do {
            return try JSONDecoder().decode(ForecastWeatherResponse.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            print("ERROR: Forecast decoding failed - Key '\(key.stringValue)' not found in: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("ERROR: Forecast decoding failed - Type '\(type)' mismatch: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("ERROR: Forecast decoding failed - Value of type '\(type)' not found: \(context.debugDescription)")
            print("ERROR: Coding path: \(context.codingPath)")
            throw WeatherError.decodingError
        } catch {
            print("ERROR: Forecast decoding failed with unknown error: \(error)")
            throw WeatherError.decodingError
        }
    }
}
