import Foundation

/// Errors that can occur when interacting with the Vercel API.
public enum VercelError: Error, LocalizedError, Equatable {
    /// Authentication failed due to invalid or missing token.
    case authenticationFailed(message: String)

    /// The API token has expired.
    case tokenExpired

    /// Rate limit exceeded. Includes reset timestamp.
    case rateLimitExceeded(resetAt: Date)

    /// Network error occurred during the request.
    case networkError(Error)

    /// Invalid response received from the API.
    case invalidResponse

    /// API returned an error with code and message.
    case apiError(code: String, message: String)

    /// Request validation failed.
    case validationError(message: String)

    /// Resource not found.
    case notFound(resource: String)

    /// Decoding error when parsing response.
    case decodingError(Error)

    /// Unknown error occurred.
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .tokenExpired:
            return "API token has expired. Please create a new token."
        case .rateLimitExceeded(let resetAt):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "Rate limit exceeded. Resets at \(formatter.string(from: resetAt))"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received from API"
        case .apiError(let code, let message):
            return "API error (\(code)): \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .notFound(let resource):
            return "Resource not found: \(resource)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }

    public static func == (lhs: VercelError, rhs: VercelError) -> Bool {
        switch (lhs, rhs) {
        case (.authenticationFailed(let lm), .authenticationFailed(let rm)):
            return lm == rm
        case (.tokenExpired, .tokenExpired):
            return true
        case (.rateLimitExceeded(let ld), .rateLimitExceeded(let rd)):
            return ld == rd
        case (.invalidResponse, .invalidResponse):
            return true
        case (.apiError(let lc, let lm), .apiError(let rc, let rm)):
            return lc == rc && lm == rm
        case (.validationError(let lm), .validationError(let rm)):
            return lm == rm
        case (.notFound(let lr), .notFound(let rr)):
            return lr == rr
        default:
            return false
        }
    }
}

/// Error response from the Vercel API.
struct APIErrorResponse: Codable, Sendable {
    let error: APIErrorDetail
}

/// Detailed error information from the API.
struct APIErrorDetail: Codable, Sendable {
    let code: String
    let message: String
}
