import Foundation

/// The main client for interacting with the Vercel API.
///
/// Create an instance with your Vercel API token to access all API endpoints.
///
/// Example:
/// ```swift
/// let client = VercelClient(token: "your-api-token")
/// let projects = try await client.projects.list()
/// ```
public final class VercelClient {
    private let httpClient: HTTPClient

    /// API for managing deployments.
    public let deployments: DeploymentsAPI

    /// API for managing projects.
    public let projects: ProjectsAPI

    /// API for managing domains.
    public let domains: DomainsAPI

    /// API for managing teams.
    public let teams: TeamsAPI

    /// Creates a new Vercel API client.
    ///
    /// - Parameters:
    ///   - token: Your Vercel API access token. Create one at https://vercel.com/account/tokens
    ///   - teamId: Optional team ID for team-scoped operations.
    ///   - session: URLSession to use for requests (default: .shared).
    public init(
        token: String,
        teamId: String? = nil,
        session: URLSession = .shared
    ) {
        self.httpClient = HTTPClient(
            token: token,
            teamId: teamId,
            session: session
        )

        self.deployments = DeploymentsAPI(client: httpClient)
        self.projects = ProjectsAPI(client: httpClient)
        self.domains = DomainsAPI(client: httpClient)
        self.teams = TeamsAPI(client: httpClient)
    }

    /// Gets the current rate limit information.
    ///
    /// - Returns: Rate limit info if available, nil otherwise.
    public func rateLimitInfo() async -> RateLimitInfo? {
        await httpClient.rateLimitInfo()
    }
}
