# VercelAPI

A comprehensive Swift package for interacting with the [Vercel REST API](https://vercel.com/docs/rest-api), following the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

## Features

- ✅ **Modern async/await API** - Built with Swift concurrency for clean, readable code
- ✅ **Comprehensive error handling** - Typed errors with localized descriptions
- ✅ **Automatic pagination** - AsyncSequence support for iterating through all pages
- ✅ **Rate limiting** - Automatic handling with retry logic
- ✅ **Type-safe models** - Codable structs for all API responses
- ✅ **Platform support** - iOS 15+, macOS 12+, tvOS 15+, watchOS 8+

## Installation

### Swift Package Manager

Add VercelAPI to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/wangqiyangX/VercelAPI.git", from: "0.1.0")
]
```

Or add it in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

## Quick Start

```swift
import VercelAPI

// Create a client with your API token
let client = VercelClient(token: "your-vercel-api-token")

// List all projects
let projects = try await client.projects.list()
for project in projects.items {
    print("Project: \(project.name)")
}

// Get a specific deployment
let deployment = try await client.deployments.get(id: "deployment-id")
print("Deployment status: \(deployment.state)")

// Create an environment variable
let envVar = try await client.projects.createEnvironmentVariable(
    projectId: "project-id",
    CreateEnvironmentVariableRequest(
        key: "API_KEY",
        value: "secret-value",
        target: [.production, .preview]
    )
)
```

## Authentication

Create an API token in your [Vercel account settings](https://vercel.com/account/tokens):

1. Go to Settings → Tokens
2. Click "Create Token"
3. Give it a descriptive name
4. Select the scope (personal or team)
5. Copy the token and store it securely

```swift
let client = VercelClient(token: "your-token-here")

// For team-scoped operations
let teamClient = VercelClient(token: "your-token", teamId: "team_xxxxx")
```

## API Coverage

### Deployments

```swift
// List deployments
let deployments = try await client.deployments.list(limit: 20)

// Iterate through all deployments automatically
for try await deployment in client.deployments.listAll() {
    print(deployment.url)
}

// Get deployment details
let deployment = try await client.deployments.get(id: "dpl_xxxxx")

// Cancel a deployment
try await client.deployments.cancel(id: "dpl_xxxxx")

// Delete a deployment
try await client.deployments.delete(id: "dpl_xxxxx")
```

### Projects

```swift
// List projects
let projects = try await client.projects.list()

// Get project
let project = try await client.projects.get(idOrName: "my-project")

// Create project
let newProject = try await client.projects.create(
    CreateProjectRequest(
        name: "my-new-project",
        framework: .nextjs,
        environmentVariables: [
            EnvironmentVariable(
                key: "DATABASE_URL",
                value: "postgres://...",
                target: [.production]
            )
        ]
    )
)

// Update project
try await client.projects.update(
    idOrName: "my-project",
    UpdateProjectRequest(framework: .vite)
)

// Delete project
try await client.projects.delete(idOrName: "my-project")

// Manage environment variables
let envVars = try await client.projects.environmentVariables(projectId: "prj_xxxxx")
try await client.projects.deleteEnvironmentVariable(projectId: "prj_xxxxx", envId: "env_xxxxx")
```

### Domains

```swift
// List domains
let domains = try await client.domains.list()

// Add a domain
let domain = try await client.domains.add(
    AddDomainRequest(name: "example.com")
)

// Verify domain
let verification = try await client.domains.verify(name: "example.com")

// Get DNS records
let records = try await client.domains.dnsRecords(domain: "example.com")

// Create DNS record
let record = try await client.domains.createDNSRecord(
    domain: "example.com",
    CreateDNSRecordRequest(
        type: "A",
        name: "@",
        value: "76.76.21.21"
    )
)

// Remove domain
try await client.domains.remove(name: "example.com")
```

### Teams

```swift
// List teams
let teams = try await client.teams.list()

// Get team details
let team = try await client.teams.get(id: "team_xxxxx")

// List team members
let members = try await client.teams.members(teamId: "team_xxxxx")

// Invite member
let invitation = try await client.teams.inviteMember(
    teamId: "team_xxxxx",
    InviteTeamMemberRequest(
        email: "user@example.com",
        role: .member
    )
)

// Update member role
try await client.teams.updateMemberRole(
    teamId: "team_xxxxx",
    userId: "user_xxxxx",
    role: .developer
)

// Remove member
try await client.teams.removeMember(
    teamId: "team_xxxxx",
    userId: "user_xxxxx"
)
```

## Pagination

The package provides two ways to handle paginated responses:

### Manual Pagination

```swift
var nextTimestamp: Int64? = nil
repeat {
    let response = try await client.projects.list(until: nextTimestamp)
    
    for project in response.items {
        print(project.name)
    }
    
    nextTimestamp = response.pagination.next
} while nextTimestamp != nil
```

### Automatic Pagination with AsyncSequence

```swift
// Automatically fetches all pages
for try await project in client.projects.listAll() {
    print(project.name)
}
```

## Error Handling

All API calls can throw `VercelError`:

```swift
do {
    let deployment = try await client.deployments.get(id: "invalid-id")
} catch VercelError.notFound(let resource) {
    print("Deployment not found: \(resource)")
} catch VercelError.authenticationFailed(let message) {
    print("Auth failed: \(message)")
} catch VercelError.rateLimitExceeded(let resetAt) {
    print("Rate limited until \(resetAt)")
} catch {
    print("Unknown error: \(error)")
}
```

### Error Types

- `authenticationFailed(message:)` - Invalid or missing API token
- `tokenExpired` - API token has expired
- `rateLimitExceeded(resetAt:)` - Rate limit exceeded
- `networkError(Error)` - Network connectivity issues
- `invalidResponse` - Malformed API response
- `apiError(code:message:)` - API returned an error
- `validationError(message:)` - Request validation failed
- `notFound(resource:)` - Resource not found
- `decodingError(Error)` - Failed to decode response

## Rate Limiting

The package automatically handles rate limiting:

```swift
// Check current rate limit status
if let rateLimit = await client.rateLimitInfo() {
    print("Remaining: \(rateLimit.remaining)/\(rateLimit.limit)")
    print("Resets at: \(rateLimit.resetAt)")
}

// The client automatically waits when rate limited
// No manual handling needed!
```

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [Vercel REST API Documentation](https://vercel.com/docs/rest-api)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Issue Tracker](https://github.com/wangqiyangX/VercelAPI/issues)
