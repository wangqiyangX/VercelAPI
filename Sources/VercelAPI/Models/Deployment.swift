import Foundation

/// Represents a deployment on Vercel.
public struct Deployment: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the deployment.
    public let id: String

    /// URL of the deployment.
    public let url: String

    /// Name of the deployment.
    public let name: String

    /// Current state of the deployment.
    public let state: DeploymentState

    /// Type of deployment (production or preview).
    public let target: DeploymentTarget?

    /// User who created the deployment.
    public let creator: DeploymentCreator?

    /// Timestamp when the deployment was created.
    public let createdAt: Int64

    /// Timestamp when the deployment was built.
    public let buildingAt: Int64?

    /// Timestamp when the deployment became ready.
    public let readyAt: Int64?

    /// Project ID this deployment belongs to.
    public let projectId: String?

    /// Team ID this deployment belongs to.
    public let teamId: String?

    /// Git metadata for the deployment.
    public let meta: DeploymentMeta?

    /// Date when the deployment was created.
    public var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }

    /// Date when the deployment was built.
    public var buildingDate: Date? {
        guard let buildingAt = buildingAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(buildingAt) / 1000.0)
    }

    /// Date when the deployment became ready.
    public var readyDate: Date? {
        guard let readyAt = readyAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(readyAt) / 1000.0)
    }
}

/// The state of a deployment.
public enum DeploymentState: String, Codable, Equatable, Sendable {
    /// Deployment is currently building.
    case building = "BUILDING"

    /// Deployment failed during build.
    case error = "ERROR"

    /// Deployment is initializing.
    case initializing = "INITIALIZING"

    /// Deployment is queued.
    case queued = "QUEUED"

    /// Deployment is ready and serving traffic.
    case ready = "READY"

    /// Deployment was canceled.
    case canceled = "CANCELED"
}

/// The target environment for a deployment.
public enum DeploymentTarget: String, Codable, Equatable, Sendable {
    /// Production deployment.
    case production

    /// Preview deployment.
    case preview

    /// Staging deployment.
    case staging
}

/// Information about the user who created a deployment.
public struct DeploymentCreator: Codable, Equatable, Sendable {
    /// User ID.
    public let uid: String

    /// Username.
    public let username: String?

    /// Email address.
    public let email: String?
}

/// Git metadata for a deployment.
public struct DeploymentMeta: Codable, Equatable, Sendable {
    /// Git commit SHA.
    public let githubCommitSha: String?

    /// Git commit message.
    public let githubCommitMessage: String?

    /// Git commit author name.
    public let githubCommitAuthorName: String?

    /// Git repository.
    public let githubRepo: String?

    /// Git branch.
    public let githubCommitRef: String?
}

/// Request body for creating a deployment.
public struct CreateDeploymentRequest: Codable, Sendable {
    /// Name of the deployment.
    public let name: String

    /// Files to deploy.
    public let files: [DeploymentFile]

    /// Target environment.
    public let target: DeploymentTarget?

    /// Project settings.
    public let projectSettings: ProjectSettings?

    /// Git metadata.
    public let gitMetadata: DeploymentMeta?

    public init(
        name: String,
        files: [DeploymentFile],
        target: DeploymentTarget? = nil,
        projectSettings: ProjectSettings? = nil,
        gitMetadata: DeploymentMeta? = nil
    ) {
        self.name = name
        self.files = files
        self.target = target
        self.projectSettings = projectSettings
        self.gitMetadata = gitMetadata
    }
}

/// A file to be deployed.
public struct DeploymentFile: Codable, Equatable, Sendable {
    /// File path relative to the project root.
    public let file: String

    /// File content (base64 encoded for binary files, plain text otherwise).
    public let data: String

    /// Encoding type.
    public let encoding: FileEncoding?

    public init(file: String, data: String, encoding: FileEncoding? = nil) {
        self.file = file
        self.data = data
        self.encoding = encoding
    }
}

/// File encoding type.
public enum FileEncoding: String, Codable, Equatable, Sendable {
    /// Base64 encoded.
    case base64

    /// UTF-8 text.
    case utf8
}

/// An event from a deployment (log entry).
public struct DeploymentEvent: Codable, Equatable, Sendable {
    /// Event type.
    public let type: String

    /// Event payload.
    public let payload: DeploymentEventPayload?

    /// Timestamp of the event.
    public let createdAt: Int64

    /// Date of the event.
    public var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }
}

/// Payload of a deployment event.
public struct DeploymentEventPayload: Codable, Equatable, Sendable {
    /// Log message text.
    public let text: String?

    /// Log level.
    public let level: String?
}

/// Response wrapper for deployments list.
struct DeploymentsResponse: Codable, Sendable {
    let deployments: [Deployment]
    let pagination: PaginationInfo
}

/// Response wrapper for single deployment.
struct DeploymentResponse: Codable, Sendable {
    // Vercel API sometimes returns deployment directly, sometimes wrapped
    // We'll handle both cases in the API implementation
}
