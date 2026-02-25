import Foundation

/// Service for fetching currency exchange rates
final class ExchangeRateService: Sendable {
    static let shared = ExchangeRateService()
    
    private init() {}
    
    /// Fetches the exchange rate from one currency to another
    /// - Parameters:
    ///   - from: Source currency code (e.g., "USD")
    ///   - to: Target currency code (e.g., "EUR")
    /// - Returns: The exchange rate multiplier
    /// - Throws: Error if the request fails or the rate cannot be determined
    func rate(from: String, to: String) async throws -> Double {
        // Use exchangerate-api.com free tier (no API key required for basic usage)
        // Alternative: You can switch to other services like fixer.io, openexchangerates.org, etc.
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(from)"
        
        guard let url = URL(string: urlString) else {
            throw ExchangeRateError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ExchangeRateError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ExchangeRateError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        guard let rate = decoded.rates[to] else {
            throw ExchangeRateError.currencyNotFound(to)
        }
        
        return rate
    }
}

// MARK: - Response Model

private struct ExchangeRateResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
}

// MARK: - Errors

enum ExchangeRateError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case currencyNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid exchange rate URL"
        case .invalidResponse:
            return "Invalid response from exchange rate service"
        case .httpError(let statusCode):
            return "Exchange rate service error: HTTP \(statusCode)"
        case .currencyNotFound(let currency):
            return "Exchange rate not found for currency: \(currency)"
        }
    }
}
