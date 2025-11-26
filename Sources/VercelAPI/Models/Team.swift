import Foundation

/// Represents a team on Vercel.
public struct Team: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the team.
    public let id: String

    /// Team slug (URL-friendly name).
    public let slug: String

    /// Team name.
    public let name: String

    /// Team avatar URL.
    public let avatar: String?

    /// Timestamp when the team was created.
    public let createdAt: Int64?

    /// Date when the team was created.
    public var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }
}

/// A member of a team.
public struct TeamMember: Codable, Identifiable, Equatable, Sendable {
    /// User ID.
    public let uid: String

    /// Role in the team.
    public let role: TeamRole

    /// Email address.
    public let email: String?

    /// Username.
    public let username: String?

    /// Display name.
    public let name: String?

    /// Avatar URL.
    public let avatar: String?

    /// Timestamp when joined.
    public let createdAt: Int64?

    /// Timestamp when confirmed.
    public let confirmedAt: Int64?

    /// Timestamp when accessed.
    public let accessedAt: Int64?

    public var id: String { uid }
}

/// Role of a team member.
public enum TeamRole: String, Codable, Equatable, Sendable {
    /// Team owner with full permissions.
    case owner = "OWNER"

    /// Team member with standard permissions.
    case member = "MEMBER"

    /// Team viewer with read-only permissions.
    case viewer = "VIEWER"

    /// Team developer with deployment permissions.
    case developer = "DEVELOPER"

    /// Team billing manager.
    case billing = "BILLING"
}

/// An invitation to join a team.
public struct TeamInvitation: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the invitation.
    public let id: String?

    /// Email address of the invitee.
    public let email: String

    /// Role being offered.
    public let role: TeamRole

    /// Timestamp when the invitation was created.
    public let createdAt: Int64?

    /// Date when the invitation was created.
    public var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }
}

/// Request body for inviting a team member.
public struct InviteTeamMemberRequest: Codable, Sendable {
    /// Email address of the person to invite.
    public let email: String

    /// Role to assign.
    public let role: TeamRole

    public init(email: String, role: TeamRole) {
        self.email = email
        self.role = role
    }
}

/// Response wrapper for teams list.
struct TeamsResponse: Codable, Sendable {
    let teams: [Team]
    let pagination: PaginationInfo?
}

/// Response wrapper for team members list.
struct TeamMembersResponse: Codable, Sendable {
    let members: [TeamMember]
    let pagination: PaginationInfo?
}
