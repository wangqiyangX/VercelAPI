import Foundation

/// Represents an environment variable in a project.
public struct EnvironmentVariable: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the environment variable.
    public let id: String?

    /// Key name of the environment variable.
    public let key: String

    /// Value of the environment variable.
    public let value: String

    /// Target environments where this variable is available.
    public let target: [EnvironmentTarget]?

    /// Type of environment variable.
    public let type: EnvironmentVariableType?

    /// Git branch for this variable (if applicable).
    public let gitBranch: String?

    /// Timestamp when created.
    public let createdAt: Int64?

    /// Timestamp when last updated.
    public let updatedAt: Int64?

    public init(
        id: String? = nil,
        key: String,
        value: String,
        target: [EnvironmentTarget]? = nil,
        type: EnvironmentVariableType? = nil,
        gitBranch: String? = nil,
        createdAt: Int64? = nil,
        updatedAt: Int64? = nil
    ) {
        self.id = id
        self.key = key
        self.value = value
        self.target = target
        self.type = type
        self.gitBranch = gitBranch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Target environment for an environment variable.
public enum EnvironmentTarget: String, Codable, Equatable, Sendable {
    /// Production environment.
    case production

    /// Preview environment.
    case preview

    /// Development environment.
    case development
}

/// Type of environment variable.
public enum EnvironmentVariableType: String, Codable, Equatable, Sendable {
    /// Plain text variable.
    case plain

    /// Secret variable (value is encrypted).
    case secret

    /// System variable (managed by Vercel).
    case system

    /// Sensitive variable.
    case sensitive
}

/// Request body for creating an environment variable.
public struct CreateEnvironmentVariableRequest: Codable, Sendable {
    /// Key name.
    public let key: String

    /// Value.
    public let value: String

    /// Target environments.
    public let target: [EnvironmentTarget]

    /// Type of variable.
    public let type: EnvironmentVariableType?

    /// Git branch (optional).
    public let gitBranch: String?

    public init(
        key: String,
        value: String,
        target: [EnvironmentTarget],
        type: EnvironmentVariableType? = nil,
        gitBranch: String? = nil
    ) {
        self.key = key
        self.value = value
        self.target = target
        self.type = type
        self.gitBranch = gitBranch
    }
}

/// Response wrapper for environment variables list.
struct EnvironmentVariablesResponse: Codable, Sendable {
    let envs: [EnvironmentVariable]
    let pagination: PaginationInfo?
}
