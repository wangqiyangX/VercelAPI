import Foundation

/// API for managing projects.
public struct ProjectsAPI {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Lists projects with pagination support.
    ///
    /// - Parameters:
    ///   - limit: Maximum number of projects to return (default: 20).
    ///   - until: Timestamp for pagination.
    /// - Returns: A paginated response containing projects.
    public func list(
        limit: Int = 20,
        until: Int64? = nil
    ) async throws -> PaginatedResponse<Project> {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]

        if let until = until {
            queryItems.append(URLQueryItem(name: "until", value: String(until)))
        }

        let response: ProjectsResponse = try await client.get(
            path: "/v9/projects",
            queryItems: queryItems
        )

        return PaginatedResponse(
            items: response.projects,
            pagination: response.pagination
        )
    }

    /// Creates an async sequence for iterating through all projects.
    ///
    /// - Parameter limit: Number of projects per page.
    /// - Returns: An async sequence of projects.
    public func listAll(limit: Int = 20) -> PaginatedIterator<Project> {
        PaginatedIterator { until in
            try await self.list(limit: limit, until: until)
        }
    }

    /// Retrieves a specific project by ID or name.
    ///
    /// - Parameter idOrName: The project ID or name.
    /// - Returns: The project details.
    public func get(idOrName: String) async throws -> Project {
        try await client.get(path: "/v9/projects/\(idOrName)")
    }

    /// Creates a new project.
    ///
    /// - Parameter request: The project creation request.
    /// - Returns: The created project.
    public func create(_ request: CreateProjectRequest) async throws -> Project {
        try await client.post(
            path: "/v9/projects",
            body: request
        )
    }

    /// Updates an existing project.
    ///
    /// - Parameters:
    ///   - idOrName: The project ID or name.
    ///   - request: The project update request.
    /// - Returns: The updated project.
    public func update(
        idOrName: String,
        _ request: UpdateProjectRequest
    ) async throws -> Project {
        try await client.patch(
            path: "/v9/projects/\(idOrName)",
            body: request
        )
    }

    /// Deletes a project.
    ///
    /// - Parameter idOrName: The project ID or name to delete.
    public func delete(idOrName: String) async throws {
        try await client.delete(path: "/v9/projects/\(idOrName)")
    }

    /// Lists environment variables for a project.
    ///
    /// - Parameter projectId: The project ID.
    /// - Returns: Array of environment variables.
    public func environmentVariables(projectId: String) async throws -> [EnvironmentVariable] {
        let response: EnvironmentVariablesResponse = try await client.get(
            path: "/v9/projects/\(projectId)/env"
        )
        return response.envs
    }

    /// Creates an environment variable for a project.
    ///
    /// - Parameters:
    ///   - projectId: The project ID.
    ///   - request: The environment variable creation request.
    /// - Returns: The created environment variable.
    public func createEnvironmentVariable(
        projectId: String,
        _ request: CreateEnvironmentVariableRequest
    ) async throws -> EnvironmentVariable {
        try await client.post(
            path: "/v10/projects/\(projectId)/env",
            body: request
        )
    }

    /// Deletes an environment variable from a project.
    ///
    /// - Parameters:
    ///   - projectId: The project ID.
    ///   - envId: The environment variable ID.
    public func deleteEnvironmentVariable(
        projectId: String,
        envId: String
    ) async throws {
        try await client.delete(
            path: "/v9/projects/\(projectId)/env/\(envId)"
        )
    }
}
