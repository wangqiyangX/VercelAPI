import Foundation

/// API for managing domains.
public struct DomainsAPI {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Lists domains with pagination support.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of domains to return (default: 20).
    ///   - until: Timestamp for pagination.
    /// - Returns: A paginated response containing domains.
    public func list(
        limit: Int = 20,
        until: Int64? = nil
    ) async throws -> PaginatedResponse<Domain> {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]

        if let until = until {
            queryItems.append(URLQueryItem(name: "until", value: String(until)))
        }

        let response: DomainsResponse = try await client.get(
            path: "/v5/domains",
            queryItems: queryItems
        )

        return PaginatedResponse(
            items: response.domains,
            pagination: response.pagination
        )
    }

    /// Creates an async sequence for iterating through all domains.
    ///
    /// - Parameter limit: Number of domains per page.
    /// - Returns: An async sequence of domains.
    public func listAll(limit: Int = 20) -> PaginatedIterator<Domain> {
        PaginatedIterator { until in
            try await self.list(limit: limit, until: until)
        }
    }

    /// Retrieves a specific domain by name.
    ///
    /// - Parameter name: The domain name.
    /// - Returns: The domain details.
    public func get(name: String) async throws -> Domain {
        try await client.get(path: "/v5/domains/\(name)")
    }

    /// Adds a new domain.
    ///
    /// - Parameter request: The domain addition request.
    /// - Returns: The added domain.
    public func add(_ request: AddDomainRequest) async throws -> Domain {
        try await client.post(
            path: "/v5/domains",
            body: request
        )
    }

    /// Removes a domain.
    ///
    /// - Parameter name: The domain name to remove.
    public func remove(name: String) async throws {
        try await client.delete(path: "/v6/domains/\(name)")
    }

    /// Verifies a domain.
    ///
    /// - Parameter name: The domain name to verify.
    /// - Returns: The verification result.
    public func verify(name: String) async throws -> DomainVerification {
        struct VerifyRequest: Codable {}
        return try await client.post(
            path: "/v5/domains/\(name)/verify",
            body: VerifyRequest()
        )
    }

    /// Lists DNS records for a domain.
    ///
    /// - Parameter domain: The domain name.
    /// - Returns: Array of DNS records.
    public func dnsRecords(domain: String) async throws -> [DNSRecord] {
        let response: DNSRecordsResponse = try await client.get(
            path: "/v4/domains/\(domain)/records"
        )
        return response.records
    }

    /// Creates a DNS record for a domain.
    ///
    /// - Parameters:
    ///   - domain: The domain name.
    ///   - request: The DNS record creation request.
    /// - Returns: The created DNS record.
    public func createDNSRecord(
        domain: String,
        _ request: CreateDNSRecordRequest
    ) async throws -> DNSRecord {
        try await client.post(
            path: "/v2/domains/\(domain)/records",
            body: request
        )
    }

    /// Deletes a DNS record from a domain.
    ///
    /// - Parameters:
    ///   - domain: The domain name.
    ///   - recordId: The DNS record ID.
    public func deleteDNSRecord(
        domain: String,
        recordId: String
    ) async throws {
        try await client.delete(
            path: "/v2/domains/\(domain)/records/\(recordId)"
        )
    }
}
