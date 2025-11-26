import Foundation

/// Represents a domain on Vercel.
public struct Domain: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the domain.
    public let id: String?

    /// Domain name.
    public let name: String

    /// Whether the domain is verified.
    public let verified: Bool?

    /// Timestamp when the domain was created.
    public let createdAt: Int64?

    /// Timestamp when the domain was bought (if purchased through Vercel).
    public let boughtAt: Int64?

    /// Timestamp when the domain expires (if purchased through Vercel).
    public let expiresAt: Int64?

    /// Service the domain is configured for.
    public let serviceType: String?

    /// Whether this is a custom domain.
    public let customDomain: Bool?

    /// Date when the domain was created.
    public var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }
}

/// DNS record for a domain.
public struct DNSRecord: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the DNS record.
    public let id: String

    /// Record type (A, AAAA, CNAME, MX, TXT, etc.).
    public let type: String

    /// Record name.
    public let name: String

    /// Record value.
    public let value: String

    /// TTL (time to live) in seconds.
    public let ttl: Int?

    /// MX priority (for MX records).
    public let mxPriority: Int?

    /// Timestamp when created.
    public let createdAt: Int64?

    /// Timestamp when last updated.
    public let updatedAt: Int64?
}

/// Domain verification status.
public struct DomainVerification: Codable, Equatable, Sendable {
    /// Whether the domain is verified.
    public let verified: Bool

    /// Verification type.
    public let verification: [VerificationRecord]?
}

/// A verification record for domain verification.
public struct VerificationRecord: Codable, Equatable, Sendable {
    /// Type of verification.
    public let type: String

    /// Domain to verify.
    public let domain: String

    /// Value to set for verification.
    public let value: String

    /// Reason if verification failed.
    public let reason: String?
}

/// Request body for adding a domain.
public struct AddDomainRequest: Codable, Sendable {
    /// Domain name to add.
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

/// Request body for creating a DNS record.
public struct CreateDNSRecordRequest: Codable, Sendable {
    /// Record type.
    public let type: String

    /// Record name.
    public let name: String

    /// Record value.
    public let value: String

    /// TTL in seconds.
    public let ttl: Int?

    /// MX priority (for MX records).
    public let mxPriority: Int?

    public init(
        type: String,
        name: String,
        value: String,
        ttl: Int? = nil,
        mxPriority: Int? = nil
    ) {
        self.type = type
        self.name = name
        self.value = value
        self.ttl = ttl
        self.mxPriority = mxPriority
    }
}

/// Response wrapper for domains list.
struct DomainsResponse: Codable, Sendable {
    let domains: [Domain]
    let pagination: PaginationInfo
}

/// Response wrapper for DNS records list.
struct DNSRecordsResponse: Codable, Sendable {
    let records: [DNSRecord]
}
