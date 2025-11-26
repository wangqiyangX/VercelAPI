import Foundation

/// API for managing teams.
public struct TeamsAPI {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    /// Lists all teams the authenticated user belongs to.
    ///
    /// - Returns: Array of teams.
    public func list() async throws -> [Team] {
        let response: TeamsResponse = try await client.get(path: "/v2/teams")
        return response.teams
    }

    /// Retrieves a specific team by ID.
    ///
    /// - Parameter id: The team ID.
    /// - Returns: The team details.
    public func get(id: String) async throws -> Team {
        try await client.get(path: "/v2/teams/\(id)")
    }

    /// Lists members of a team.
    ///
    /// - Parameter teamId: The team ID.
    /// - Returns: Array of team members.
    public func members(teamId: String) async throws -> [TeamMember] {
        let response: TeamMembersResponse = try await client.get(
            path: "/v2/teams/\(teamId)/members"
        )
        return response.members
    }

    /// Invites a user to join a team.
    ///
    /// - Parameters:
    ///   - teamId: The team ID.
    ///   - request: The invitation request.
    /// - Returns: The created invitation.
    public func inviteMember(
        teamId: String,
        _ request: InviteTeamMemberRequest
    ) async throws -> TeamInvitation {
        try await client.post(
            path: "/v1/teams/\(teamId)/members",
            body: request
        )
    }

    /// Removes a member from a team.
    ///
    /// - Parameters:
    ///   - teamId: The team ID.
    ///   - userId: The user ID to remove.
    public func removeMember(
        teamId: String,
        userId: String
    ) async throws {
        try await client.delete(
            path: "/v1/teams/\(teamId)/members/\(userId)"
        )
    }

    /// Updates a team member's role.
    ///
    /// - Parameters:
    ///   - teamId: The team ID.
    ///   - userId: The user ID.
    ///   - role: The new role.
    /// - Returns: The updated team member.
    public func updateMemberRole(
        teamId: String,
        userId: String,
        role: TeamRole
    ) async throws -> TeamMember {
        struct UpdateRoleRequest: Codable {
            let role: TeamRole
        }

        return try await client.patch(
            path: "/v1/teams/\(teamId)/members/\(userId)",
            body: UpdateRoleRequest(role: role)
        )
    }
}
