import Foundation

/// API for managing deployments.
public struct DeploymentsAPI {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Lists deployments with pagination support.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of deployments to return (default: 20).
    ///   - until: Timestamp for pagination (fetches deployments before this time).
    ///   - projectId: Filter by project ID.
    ///   - state: Filter by deployment state.
    /// - Returns: A paginated response containing deployments.
    public func list(
        limit: Int = 20,
        until: Int64? = nil,
        projectId: String? = nil,
        state: DeploymentState? = nil
    ) async throws -> PaginatedResponse<Deployment> {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]

        if let until = until {
            queryItems.append(URLQueryItem(name: "until", value: String(until)))
        }

        if let projectId = projectId {
            queryItems.append(URLQueryItem(name: "projectId", value: projectId))
        }

        if let state = state {
            queryItems.append(URLQueryItem(name: "state", value: state.rawValue))
        }

        let response: DeploymentsResponse = try await client.get(
            path: "/v6/deployments",
            queryItems: queryItems
        )

        return PaginatedResponse(
            items: response.deployments,
            pagination: response.pagination
        )
    }

    /// Creates an async sequence for iterating through all deployments.
    ///
    /// - Parameters:
    ///   - limit: Number of deployments per page.
    ///   - projectId: Filter by project ID.
    ///   - state: Filter by deployment state.
    /// - Returns: An async sequence of deployments.
    public func listAll(
        limit: Int = 20,
        projectId: String? = nil,
        state: DeploymentState? = nil
    ) -> PaginatedIterator<Deployment> {
        PaginatedIterator { until in
            try await self.list(
                limit: limit,
                until: until,
                projectId: projectId,
                state: state
            )
        }
    }

    /// Retrieves a specific deployment by ID.
    ///
    /// - Parameter id: The deployment ID.
    /// - Returns: The deployment details.
    public func get(id: String) async throws -> Deployment {
        try await client.get(path: "/v13/deployments/\(id)")
    }

    /// Creates a new deployment.
    ///
    /// - Parameter request: The deployment creation request.
    /// - Returns: The created deployment.
    public func create(_ request: CreateDeploymentRequest) async throws -> Deployment {
        try await client.post(
            path: "/v13/deployments",
            body: request
        )
    }

    /// Cancels a deployment.
    ///
    /// - Parameter id: The deployment ID to cancel.
    /// - Returns: The updated deployment.
    public func cancel(id: String) async throws -> Deployment {
        struct CancelRequest: Codable {}
        return try await client.patch(
            path: "/v12/deployments/\(id)/cancel",
            body: CancelRequest()
        )
    }

    /// Deletes a deployment.
    ///
    /// - Parameter id: The deployment ID to delete.
    public func delete(id: String) async throws {
        try await client.delete(path: "/v13/deployments/\(id)")
    }
}
