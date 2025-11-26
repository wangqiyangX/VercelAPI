import Foundation

/// Rate limit information from API response headers.
public struct RateLimitInfo: Equatable, Sendable {
    /// Maximum number of requests allowed in the time window.
    public let limit: Int

    /// Number of requests remaining in the current time window.
    public let remaining: Int

    /// Date when the rate limit resets.
    public let resetAt: Date

    /// Whether the rate limit has been exceeded.
    public var isExceeded: Bool {
        remaining <= 0
    }

    /// Time interval until the rate limit resets.
    public var timeUntilReset: TimeInterval {
        resetAt.timeIntervalSinceNow
    }
}

/// Handles rate limiting for API requests.
actor RateLimiter {
    private var currentInfo: RateLimitInfo?

    /// Updates rate limit information from response headers.
    func update(from headers: [AnyHashable: Any]) {
        guard let limitStr = headers["X-RateLimit-Limit"] as? String,
            let remainingStr = headers["X-RateLimit-Remaining"] as? String,
            let resetStr = headers["X-RateLimit-Reset"] as? String,
            let limit = Int(limitStr),
            let remaining = Int(remainingStr),
            let resetTimestamp = TimeInterval(resetStr)
        else {
            return
        }

        let resetDate = Date(timeIntervalSince1970: resetTimestamp)
        currentInfo = RateLimitInfo(
            limit: limit,
            remaining: remaining,
            resetAt: resetDate
        )
    }

    /// Gets the current rate limit information.
    func info() -> RateLimitInfo? {
        currentInfo
    }

    /// Waits until the rate limit resets if it's currently exceeded.
    func waitIfNeeded() async throws {
        guard let info = currentInfo, info.isExceeded else {
            return
        }

        let waitTime = max(0, info.timeUntilReset)
        if waitTime > 0 {
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
    }
}
