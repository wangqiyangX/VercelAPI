# VercelAPI Examples

Comprehensive examples for using the VercelAPI Swift package.

## Table of Contents

- [Basic Setup](#basic-setup)
- [Deployments](#deployments)
- [Projects](#projects)
- [Environment Variables](#environment-variables)
- [Domains](#domains)
- [Teams](#teams)
- [Error Handling](#error-handling)
- [Pagination](#pagination)

## Basic Setup

```swift
import VercelAPI

// Initialize the client
let client = VercelClient(token: "your-vercel-api-token")

// For team-scoped operations
let teamClient = VercelClient(
    token: "your-token",
    teamId: "team_xxxxx"
)
```

## Deployments

### List All Deployments

```swift
// Get first page
let response = try await client.deployments.list(limit: 20)
print("Found \(response.pagination.count) deployments")

for deployment in response.items {
    print("\(deployment.name) - \(deployment.state)")
}
```

### Iterate Through All Deployments

```swift
// Automatically handles pagination
for try await deployment in client.deployments.listAll() {
    print("URL: \(deployment.url)")
    print("State: \(deployment.state)")
    print("Created: \(deployment.createdDate)")
    
    if deployment.state == .ready {
        print("✅ Deployment is live!")
    }
}
```

### Filter Deployments

```swift
// Filter by project
let projectDeployments = try await client.deployments.list(
    projectId: "prj_xxxxx",
    state: .ready
)

// Filter by state
let buildingDeployments = try await client.deployments.list(
    state: .building
)
```

### Get Deployment Details

```swift
let deployment = try await client.deployments.get(id: "dpl_xxxxx")

print("Name: \(deployment.name)")
print("URL: \(deployment.url)")
print("State: \(deployment.state)")
print("Target: \(deployment.target?.rawValue ?? "unknown")")

if let creator = deployment.creator {
    print("Created by: \(creator.username ?? creator.uid)")
}

if let meta = deployment.meta {
    print("Git commit: \(meta.githubCommitSha ?? "unknown")")
    print("Branch: \(meta.githubCommitRef ?? "unknown")")
}
```

### Cancel a Deployment

```swift
let canceledDeployment = try await client.deployments.cancel(id: "dpl_xxxxx")
print("Deployment canceled: \(canceledDeployment.state)")
```

## Projects

### Create a New Project

```swift
let project = try await client.projects.create(
    CreateProjectRequest(
        name: "my-awesome-app",
        framework: .nextjs,
        buildCommand: "npm run build",
        outputDirectory: ".next",
        environmentVariables: [
            EnvironmentVariable(
                key: "DATABASE_URL",
                value: "postgres://user:pass@host:5432/db",
                target: [.production]
            ),
            EnvironmentVariable(
                key: "API_KEY",
                value: "dev-key",
                target: [.development, .preview]
            )
        ]
    )
)

print("Created project: \(project.id)")
```

### Update a Project

```swift
let updated = try await client.projects.update(
    idOrName: "my-project",
    UpdateProjectRequest(
        framework: .vite,
        buildCommand: "vite build"
    )
)

print("Updated project framework to: \(updated.framework?.rawValue ?? "unknown")")
```

### List All Projects

```swift
// Manual pagination
var allProjects: [Project] = []
var nextTimestamp: Int64? = nil

repeat {
    let response = try await client.projects.list(until: nextTimestamp)
    allProjects.append(contentsOf: response.items)
    nextTimestamp = response.pagination.next
} while nextTimestamp != nil

print("Total projects: \(allProjects.count)")

// Or use automatic pagination
for try await project in client.projects.listAll() {
    print("\(project.name) - \(project.framework?.rawValue ?? "unknown")")
}
```

## Environment Variables

### Add Environment Variable

```swift
let envVar = try await client.projects.createEnvironmentVariable(
    projectId: "prj_xxxxx",
    CreateEnvironmentVariableRequest(
        key: "STRIPE_SECRET_KEY",
        value: "sk_test_xxxxx",
        target: [.production],
        type: .secret
    )
)

print("Created env var: \(envVar.key)")
```

### List Environment Variables

```swift
let envVars = try await client.projects.environmentVariables(
    projectId: "prj_xxxxx"
)

for envVar in envVars {
    print("\(envVar.key) - Targets: \(envVar.target?.map { $0.rawValue } ?? [])")
}
```

### Delete Environment Variable

```swift
try await client.projects.deleteEnvironmentVariable(
    projectId: "prj_xxxxx",
    envId: "env_xxxxx"
)
print("Environment variable deleted")
```

## Domains

### Add a Custom Domain

```swift
let domain = try await client.domains.add(
    AddDomainRequest(name: "example.com")
)

print("Domain added: \(domain.name)")
print("Verified: \(domain.verified ?? false)")
```

### Verify Domain

```swift
let verification = try await client.domains.verify(name: "example.com")

if verification.verified {
    print("✅ Domain is verified!")
} else {
    print("❌ Domain verification pending")
    
    if let records = verification.verification {
        for record in records {
            print("Add \(record.type) record:")
            print("  Name: \(record.domain)")
            print("  Value: \(record.value)")
        }
    }
}
```

### Manage DNS Records

```swift
// List DNS records
let records = try await client.domains.dnsRecords(domain: "example.com")

for record in records {
    print("\(record.type) \(record.name) -> \(record.value)")
}

// Create A record
let aRecord = try await client.domains.createDNSRecord(
    domain: "example.com",
    CreateDNSRecordRequest(
        type: "A",
        name: "@",
        value: "76.76.21.21",
        ttl: 3600
    )
)

// Create CNAME record
let cnameRecord = try await client.domains.createDNSRecord(
    domain: "example.com",
    CreateDNSRecordRequest(
        type: "CNAME",
        name: "www",
        value: "cname.vercel-dns.com"
    )
)

// Delete DNS record
try await client.domains.deleteDNSRecord(
    domain: "example.com",
    recordId: aRecord.id
)
```

## Teams

### List Teams

```swift
let teams = try await client.teams.list()

for team in teams {
    print("Team: \(team.name) (\(team.slug))")
}
```

### Manage Team Members

```swift
// List members
let members = try await client.teams.members(teamId: "team_xxxxx")

for member in members {
    print("\(member.name ?? member.email ?? member.uid) - \(member.role.rawValue)")
}

// Invite new member
let invitation = try await client.teams.inviteMember(
    teamId: "team_xxxxx",
    InviteTeamMemberRequest(
        email: "newmember@example.com",
        role: .developer
    )
)

print("Invitation sent to: \(invitation.email)")

// Update member role
try await client.teams.updateMemberRole(
    teamId: "team_xxxxx",
    userId: "user_xxxxx",
    role: .member
)

// Remove member
try await client.teams.removeMember(
    teamId: "team_xxxxx",
    userId: "user_xxxxx"
)
```

## Error Handling

### Comprehensive Error Handling

```swift
func deployProject() async {
    do {
        let deployment = try await client.deployments.get(id: "dpl_xxxxx")
        print("Deployment: \(deployment.url)")
        
    } catch VercelError.authenticationFailed(let message) {
        print("❌ Authentication failed: \(message)")
        print("Please check your API token")
        
    } catch VercelError.tokenExpired {
        print("❌ Token expired - please create a new one")
        
    } catch VercelError.rateLimitExceeded(let resetAt) {
        print("❌ Rate limit exceeded")
        print("Resets at: \(resetAt)")
        print("Please wait before retrying")
        
    } catch VercelError.notFound(let resource) {
        print("❌ Resource not found: \(resource)")
        
    } catch VercelError.apiError(let code, let message) {
        print("❌ API Error [\(code)]: \(message)")
        
    } catch VercelError.networkError(let error) {
        print("❌ Network error: \(error.localizedDescription)")
        print("Please check your internet connection")
        
    } catch {
        print("❌ Unexpected error: \(error)")
    }
}
```

### Retry Logic with Rate Limiting

```swift
func fetchWithRetry<T>(
    maxRetries: Int = 3,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    
    for attempt in 1...maxRetries {
        do {
            return try await operation()
        } catch VercelError.rateLimitExceeded(let resetAt) {
            if attempt < maxRetries {
                let waitTime = resetAt.timeIntervalSinceNow
                print("Rate limited, waiting \(Int(waitTime))s...")
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                continue
            }
            throw VercelError.rateLimitExceeded(resetAt: resetAt)
        } catch {
            lastError = error
            if attempt < maxRetries {
                print("Attempt \(attempt) failed, retrying...")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                continue
            }
        }
    }
    
    throw lastError ?? VercelError.unknown(NSError(domain: "Unknown", code: -1))
}

// Usage
let projects = try await fetchWithRetry {
    try await client.projects.list()
}
```

## Pagination

### Manual Pagination with Progress

```swift
func fetchAllProjects() async throws -> [Project] {
    var allProjects: [Project] = []
    var nextTimestamp: Int64? = nil
    var pageNumber = 1
    
    repeat {
        print("Fetching page \(pageNumber)...")
        
        let response = try await client.projects.list(
            limit: 100,
            until: nextTimestamp
        )
        
        allProjects.append(contentsOf: response.items)
        nextTimestamp = response.pagination.next
        
        print("  Got \(response.items.count) projects")
        print("  Total so far: \(allProjects.count)")
        
        pageNumber += 1
        
    } while nextTimestamp != nil
    
    print("✅ Fetched all \(allProjects.count) projects")
    return allProjects
}
```

### Automatic Pagination with Filtering

```swift
// Find all Next.js projects
var nextjsProjects: [Project] = []

for try await project in client.projects.listAll() {
    if project.framework == .nextjs {
        nextjsProjects.append(project)
    }
}

print("Found \(nextjsProjects.count) Next.js projects")
```

### Rate Limit Monitoring

```swift
// Check rate limit before making requests
if let rateLimit = await client.rateLimitInfo() {
    print("Rate Limit Status:")
    print("  Limit: \(rateLimit.limit)")
    print("  Remaining: \(rateLimit.remaining)")
    print("  Resets at: \(rateLimit.resetAt)")
    
    if rateLimit.remaining < 10 {
        print("⚠️  Warning: Low rate limit remaining!")
    }
}

// Make API calls
let projects = try await client.projects.list()

// Check again after
if let rateLimit = await client.rateLimitInfo() {
    print("After request - Remaining: \(rateLimit.remaining)")
}
```
