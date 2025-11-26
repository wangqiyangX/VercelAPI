import Foundation

/// Internal HTTP client for making requests to the Vercel API.
actor HTTPClient {
    private let baseURL = URL(string: "https://api.vercel.com")!
    private let token: String
    private let teamId: String?
    private let session: URLSession
    private let rateLimiter = RateLimiter()
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(token: String, teamId: String? = nil, session: URLSession = .shared) {
        self.token = token
        self.teamId = teamId
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    /// Performs a GET request.
    func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        try await request(method: "GET", path: path, queryItems: queryItems, body: nil as Data?)
    }

    /// Performs a POST request.
    func post<T: Decodable, B: Encodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        body: B?
    ) async throws -> T {
        try await request(method: "POST", path: path, queryItems: queryItems, body: body)
    }

    /// Performs a PATCH request.
    func patch<T: Decodable, B: Encodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        body: B?
    ) async throws -> T {
        try await request(method: "PATCH", path: path, queryItems: queryItems, body: body)
    }

    /// Performs a DELETE request.
    func delete(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws {
        let _: EmptyResponse = try await request(
            method: "DELETE",
            path: path,
            queryItems: queryItems,
            body: nil as Data?
        )
    }

    /// Performs an HTTP request.
    private func request<T: Decodable, B: Encodable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem],
        body: B?
    ) async throws -> T {
        // Wait if rate limit is exceeded
        try await rateLimiter.waitIfNeeded()

        // Build URL
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!

        // Add team ID if provided
        var allQueryItems = queryItems
        if let teamId = teamId {
            allQueryItems.append(URLQueryItem(name: "teamId", value: teamId))
        }

        if !allQueryItems.isEmpty {
            components.queryItems = allQueryItems
        }

        guard let url = components.url else {
            throw VercelError.validationError(message: "Invalid URL")
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add body if provided
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        // Perform request
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VercelError.invalidResponse
        }

        // Update rate limit info
        await rateLimiter.update(from: httpResponse.allHeaderFields)

        // Handle response
        try handleHTTPResponse(httpResponse, data: data)

        // Decode response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw VercelError.decodingError(error)
        }
    }

    /// Handles HTTP response status codes.
    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return

        case 401:
            // Try to decode error message
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw VercelError.authenticationFailed(message: errorResponse.error.message)
            }
            throw VercelError.authenticationFailed(message: "Unauthorized")

        case 403:
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data),
                errorResponse.error.code == "token_expired"
            {
                throw VercelError.tokenExpired
            }
            throw VercelError.authenticationFailed(message: "Forbidden")

        case 404:
            throw VercelError.notFound(resource: response.url?.path ?? "unknown")

        case 429:
            // Rate limit exceeded
            if let resetStr = response.allHeaderFields["X-RateLimit-Reset"] as? String,
                let resetTimestamp = TimeInterval(resetStr)
            {
                let resetDate = Date(timeIntervalSince1970: resetTimestamp)
                throw VercelError.rateLimitExceeded(resetAt: resetDate)
            }
            throw VercelError.rateLimitExceeded(resetAt: Date().addingTimeInterval(60))

        default:
            // Try to decode API error
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw VercelError.apiError(
                    code: errorResponse.error.code,
                    message: errorResponse.error.message
                )
            }
            throw VercelError.apiError(
                code: "http_\(response.statusCode)",
                message: "HTTP error \(response.statusCode)"
            )
        }
    }

    /// Gets current rate limit information.
    func rateLimitInfo() async -> RateLimitInfo? {
        await rateLimiter.info()
    }
}

/// Empty response for DELETE requests.
private struct EmptyResponse: Decodable {}
