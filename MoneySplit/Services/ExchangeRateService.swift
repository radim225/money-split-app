import Foundation

actor ExchangeRateService {
    static let shared = ExchangeRateService()

    private init() {}

    /// Fetches the live exchange rate from Frankfurter.app (ECB, ~32 currencies, no API key).
    /// Returns 1.0 if `from == to`.
    func rate(from: String, to: String) async throws -> Double {
        guard from != to else { return 1.0 }
        let urlString = "https://api.frankfurter.app/latest?from=\(from)&to=\(to)"
        guard let url = URL(string: urlString) else { throw ExchangeRateError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw ExchangeRateError.httpError(http.statusCode)
        }
        let decoded = try JSONDecoder().decode(FrankfurterResponse.self, from: data)
        guard let rate = decoded.rates[to] else { throw ExchangeRateError.rateNotFound }
        return rate
    }
}

private struct FrankfurterResponse: Decodable {
    let rates: [String: Double]
}

enum ExchangeRateError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case rateNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:      return "Invalid URL"
        case .httpError(let c): return "Server error (\(c))"
        case .rateNotFound:    return "Exchange rate not available for this currency pair"
        }
    }
}
