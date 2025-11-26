import Foundation

/// Represents a project on Vercel.
public struct Project: Codable, Identifiable, Equatable, Sendable {
    /// Unique identifier for the project.
    public let id: String

    /// Name of the project.
    public let name: String

    /// Account ID that owns the project.
    public let accountId: String?

    /// Timestamp when the project was created.
    public let createdAt: Int64?

    /// Timestamp when the project was last updated.
    public let updatedAt: Int64?

    /// Framework used by the project.
    public let framework: Framework?

    /// Build command.
    public let buildCommand: String?

    /// Development command.
    public let devCommand: String?

    /// Install command.
    public let installCommand: String?

    /// Output directory.
    public let outputDirectory: String?

    /// Root directory.
    public let rootDirectory: String?

    /// Git repository information.
    public let link: ProjectLink?

    /// Date when the project was created.
    public var createdDate: Date? {
        guard let createdAt = createdAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000.0)
    }

    /// Date when the project was last updated.
    public var updatedDate: Date? {
        guard let updatedAt = updatedAt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(updatedAt) / 1000.0)
    }
}

/// Framework type for a project.
public enum Framework: String, Codable, Equatable, Sendable {
    case nextjs
    case vite
    case gatsby
    case hugo
    case jekyll
    case nuxtjs = "nuxtjs"
    case sveltekit
    case astro
    case remix
    case solidstart
    case vue
    case angular
    case react
    case svelte
    case preact
    case docusaurus
    case eleventy
    case hexo
    case other
}

/// Git repository link for a project.
public struct ProjectLink: Codable, Equatable, Sendable {
    /// Type of git provider.
    public let type: String?

    /// Repository name.
    public let repo: String?

    /// Repository ID.
    public let repoId: Int?

    /// Git provider (github, gitlab, bitbucket).
    public let gitProvider: String?

    /// Production branch.
    public let productionBranch: String?
}

/// Project settings for deployment.
public struct ProjectSettings: Codable, Equatable, Sendable {
    /// Build command.
    public let buildCommand: String?

    /// Development command.
    public let devCommand: String?

    /// Framework.
    public let framework: Framework?

    /// Install command.
    public let installCommand: String?

    /// Output directory.
    public let outputDirectory: String?

    /// Root directory.
    public let rootDirectory: String?

    public init(
        buildCommand: String? = nil,
        devCommand: String? = nil,
        framework: Framework? = nil,
        installCommand: String? = nil,
        outputDirectory: String? = nil,
        rootDirectory: String? = nil
    ) {
        self.buildCommand = buildCommand
        self.devCommand = devCommand
        self.framework = framework
        self.installCommand = installCommand
        self.outputDirectory = outputDirectory
        self.rootDirectory = rootDirectory
    }
}

/// Request body for creating a project.
public struct CreateProjectRequest: Codable, Sendable {
    /// Name of the project.
    public let name: String

    /// Framework.
    public let framework: Framework?

    /// Build command.
    public let buildCommand: String?

    /// Development command.
    public let devCommand: String?

    /// Install command.
    public let installCommand: String?

    /// Output directory.
    public let outputDirectory: String?

    /// Root directory.
    public let rootDirectory: String?

    /// Environment variables.
    public let environmentVariables: [EnvironmentVariable]?

    /// Git repository.
    public let gitRepository: GitRepository?

    public init(
        name: String,
        framework: Framework? = nil,
        buildCommand: String? = nil,
        devCommand: String? = nil,
        installCommand: String? = nil,
        outputDirectory: String? = nil,
        rootDirectory: String? = nil,
        environmentVariables: [EnvironmentVariable]? = nil,
        gitRepository: GitRepository? = nil
    ) {
        self.name = name
        self.framework = framework
        self.buildCommand = buildCommand
        self.devCommand = devCommand
        self.installCommand = installCommand
        self.outputDirectory = outputDirectory
        self.rootDirectory = rootDirectory
        self.environmentVariables = environmentVariables
        self.gitRepository = gitRepository
    }
}

/// Request body for updating a project.
public struct UpdateProjectRequest: Codable, Sendable {
    /// Name of the project.
    public let name: String?

    /// Framework.
    public let framework: Framework?

    /// Build command.
    public let buildCommand: String?

    /// Development command.
    public let devCommand: String?

    /// Install command.
    public let installCommand: String?

    /// Output directory.
    public let outputDirectory: String?

    /// Root directory.
    public let rootDirectory: String?

    public init(
        name: String? = nil,
        framework: Framework? = nil,
        buildCommand: String? = nil,
        devCommand: String? = nil,
        installCommand: String? = nil,
        outputDirectory: String? = nil,
        rootDirectory: String? = nil
    ) {
        self.name = name
        self.framework = framework
        self.buildCommand = buildCommand
        self.devCommand = devCommand
        self.installCommand = installCommand
        self.outputDirectory = outputDirectory
        self.rootDirectory = rootDirectory
    }
}

/// Git repository information for project creation.
public struct GitRepository: Codable, Equatable, Sendable {
    /// Type of git provider.
    public let type: String

    /// Repository URL or identifier.
    public let repo: String

    public init(type: String, repo: String) {
        self.type = type
        self.repo = repo
    }
}

/// Response wrapper for projects list.
struct ProjectsResponse: Codable, Sendable {
    let projects: [Project]
    let pagination: PaginationInfo
}
