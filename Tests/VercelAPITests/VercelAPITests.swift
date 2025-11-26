import XCTest

@testable import VercelAPI

final class VercelErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let authError = VercelError.authenticationFailed(message: "Invalid token")
        XCTAssertEqual(authError.errorDescription, "Authentication failed: Invalid token")

        let tokenExpired = VercelError.tokenExpired
        XCTAssertEqual(
            tokenExpired.errorDescription, "API token has expired. Please create a new token.")

        let notFound = VercelError.notFound(resource: "deployment")
        XCTAssertEqual(notFound.errorDescription, "Resource not found: deployment")

        let validation = VercelError.validationError(message: "Invalid input")
        XCTAssertEqual(validation.errorDescription, "Validation error: Invalid input")
    }

    func testErrorEquality() {
        let error1 = VercelError.authenticationFailed(message: "test")
        let error2 = VercelError.authenticationFailed(message: "test")
        let error3 = VercelError.authenticationFailed(message: "different")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)

        let tokenExpired1 = VercelError.tokenExpired
        let tokenExpired2 = VercelError.tokenExpired
        XCTAssertEqual(tokenExpired1, tokenExpired2)
    }

    func testRateLimitError() {
        let resetDate = Date(timeIntervalSince1970: 1_700_000_000)
        let error = VercelError.rateLimitExceeded(resetAt: resetDate)

        XCTAssertTrue(error.errorDescription?.contains("Rate limit exceeded") ?? false)
    }
}

final class PaginationTests: XCTestCase {
    func testPaginationInfo() {
        let info = PaginationInfo(
            count: 20,
            next: 1_700_000_000_000,
            prev: 1_699_900_000_000
        )

        XCTAssertEqual(info.count, 20)
        XCTAssertTrue(info.hasNextPage)
        XCTAssertTrue(info.hasPreviousPage)
        XCTAssertNotNil(info.nextDate)
        XCTAssertNotNil(info.previousDate)
    }

    func testPaginationInfoWithoutNext() {
        let info = PaginationInfo(
            count: 10,
            next: nil,
            prev: 1_699_900_000_000
        )

        XCTAssertFalse(info.hasNextPage)
        XCTAssertTrue(info.hasPreviousPage)
        XCTAssertNil(info.nextDate)
    }
}

final class DeploymentModelTests: XCTestCase {
    func testDeploymentState() {
        XCTAssertEqual(DeploymentState.ready.rawValue, "READY")
        XCTAssertEqual(DeploymentState.building.rawValue, "BUILDING")
        XCTAssertEqual(DeploymentState.error.rawValue, "ERROR")
    }

    func testDeploymentTarget() {
        XCTAssertEqual(DeploymentTarget.production.rawValue, "production")
        XCTAssertEqual(DeploymentTarget.preview.rawValue, "preview")
    }

    func testFileEncoding() {
        XCTAssertEqual(FileEncoding.base64.rawValue, "base64")
        XCTAssertEqual(FileEncoding.utf8.rawValue, "utf8")
    }
}

final class ProjectModelTests: XCTestCase {
    func testFramework() {
        XCTAssertEqual(Framework.nextjs.rawValue, "nextjs")
        XCTAssertEqual(Framework.vite.rawValue, "vite")
        XCTAssertEqual(Framework.gatsby.rawValue, "gatsby")
    }
}

final class TeamModelTests: XCTestCase {
    func testTeamRole() {
        XCTAssertEqual(TeamRole.owner.rawValue, "OWNER")
        XCTAssertEqual(TeamRole.member.rawValue, "MEMBER")
        XCTAssertEqual(TeamRole.viewer.rawValue, "VIEWER")
        XCTAssertEqual(TeamRole.developer.rawValue, "DEVELOPER")
    }
}

final class EnvironmentVariableModelTests: XCTestCase {
    func testEnvironmentTarget() {
        XCTAssertEqual(EnvironmentTarget.production.rawValue, "production")
        XCTAssertEqual(EnvironmentTarget.preview.rawValue, "preview")
        XCTAssertEqual(EnvironmentTarget.development.rawValue, "development")
    }

    func testEnvironmentVariableType() {
        XCTAssertEqual(EnvironmentVariableType.plain.rawValue, "plain")
        XCTAssertEqual(EnvironmentVariableType.secret.rawValue, "secret")
        XCTAssertEqual(EnvironmentVariableType.system.rawValue, "system")
    }
}

final class RateLimiterTests: XCTestCase {
    func testRateLimitInfo() {
        let resetDate = Date().addingTimeInterval(60)
        let info = RateLimitInfo(
            limit: 100,
            remaining: 50,
            resetAt: resetDate
        )

        XCTAssertEqual(info.limit, 100)
        XCTAssertEqual(info.remaining, 50)
        XCTAssertFalse(info.isExceeded)
        XCTAssertGreaterThan(info.timeUntilReset, 0)
    }

    func testRateLimitExceeded() {
        let resetDate = Date().addingTimeInterval(60)
        let info = RateLimitInfo(
            limit: 100,
            remaining: 0,
            resetAt: resetDate
        )

        XCTAssertTrue(info.isExceeded)
    }
}

// MARK: - Integration Tests

/// Integration tests that make real API calls to Vercel.
/// These tests are skipped by default unless VERCEL_API_TOKEN environment variable is set.
///
/// To run these tests:
/// 1. Create a Vercel API token at https://vercel.com/account/tokens
/// 2. Export it: `export VERCEL_API_TOKEN=your_token_here`
/// 3. Run tests: `swift test`
///
/// Note: These tests will create and delete real resources in your Vercel account.
/// Use a test account or be prepared for potential side effects.
final class IntegrationTests: XCTestCase {

    private var client: VercelClient?
    private var shouldSkip: Bool {
        client == nil
    }

    override func setUp() async throws {
        try await super.setUp()

        // Only run integration tests if API token is provided
        if let token = ProcessInfo.processInfo.environment["VERCEL_API_TOKEN"],
            !token.isEmpty
        {
            client = VercelClient(token: token)
            print("✅ Integration tests enabled with API token")
        } else {
            print("⏭️  Skipping integration tests - set VERCEL_API_TOKEN to enable")
        }
    }

    // MARK: - Teams Tests

    func testListTeams() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled - set VERCEL_API_TOKEN environment variable")
        }

        let teams = try await client.teams.list()

        XCTAssertNotNil(teams)
        print("📋 Found \(teams.count) team(s)")

        for team in teams {
            XCTAssertFalse(team.id.isEmpty)
            XCTAssertFalse(team.slug.isEmpty)
            XCTAssertFalse(team.name.isEmpty)
            print("  - \(team.name) (\(team.slug))")
        }
    }

    func testGetTeamMembers() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let teams = try await client.teams.list()
        guard let firstTeam = teams.first else {
            throw XCTSkip("No teams available for testing")
        }

        let members = try await client.teams.members(teamId: firstTeam.id)

        XCTAssertNotNil(members)
        print("👥 Team '\(firstTeam.name)' has \(members.count) member(s)")

        for member in members {
            XCTAssertFalse(member.uid.isEmpty)
            print("  - \(member.name ?? member.email ?? member.uid) (\(member.role.rawValue))")
        }
    }

    // MARK: - Projects Tests

    func testListProjects() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.projects.list(limit: 10)

        XCTAssertNotNil(response.items)
        print("📦 Found \(response.items.count) project(s)")

        for project in response.items {
            XCTAssertFalse(project.id.isEmpty)
            XCTAssertFalse(project.name.isEmpty)
            print("  - \(project.name) [\(project.framework?.rawValue ?? "unknown")]")
        }

        // Test pagination info
        XCTAssertEqual(response.pagination.count, response.items.count)
    }

    func testListAllProjectsWithPagination() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        var projectCount = 0
        var pageCount = 0

        // Limit to first 3 pages to avoid long test times
        for try await project in client.projects.listAll(limit: 5) {
            projectCount += 1
            print("  Project \(projectCount): \(project.name)")

            if projectCount % 5 == 0 {
                pageCount += 1
            }

            // Stop after 15 projects (3 pages)
            if projectCount >= 15 {
                break
            }
        }

        print("📄 Fetched \(projectCount) projects across ~\(pageCount) pages")
        XCTAssertGreaterThan(projectCount, 0)
    }

    func testGetProject() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.projects.list(limit: 1)
        guard let firstProject = response.items.first else {
            throw XCTSkip("No projects available for testing")
        }

        let project = try await client.projects.get(idOrName: firstProject.id)

        XCTAssertEqual(project.id, firstProject.id)
        XCTAssertEqual(project.name, firstProject.name)
        print("✅ Retrieved project: \(project.name)")

        if let framework = project.framework {
            print("   Framework: \(framework.rawValue)")
        }
        if let buildCommand = project.buildCommand {
            print("   Build command: \(buildCommand)")
        }
    }

    func testGetEnvironmentVariables() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.projects.list(limit: 1)
        guard let firstProject = response.items.first else {
            throw XCTSkip("No projects available")
        }

        let envVars = try await client.projects.environmentVariables(projectId: firstProject.id)

        print("🔐 Project '\(firstProject.name)' has \(envVars.count) environment variable(s)")

        for envVar in envVars {
            XCTAssertFalse(envVar.key.isEmpty)
            let targets = envVar.target?.map { $0.rawValue }.joined(separator: ", ") ?? "none"
            print("  - \(envVar.key) [targets: \(targets)]")
        }
    }

    // MARK: - Deployments Tests

    func testListDeployments() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.deployments.list(limit: 10)

        XCTAssertNotNil(response.items)
        print("🚀 Found \(response.items.count) deployment(s)")

        for deployment in response.items {
            XCTAssertFalse(deployment.id.isEmpty)
            XCTAssertFalse(deployment.url.isEmpty)
            print("  - \(deployment.name) (\(deployment.state.rawValue)) - \(deployment.url)")
        }
    }

    func testGetDeployment() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.deployments.list(limit: 1)
        guard let firstDeployment = response.items.first else {
            throw XCTSkip("No deployments available")
        }

        let deployment = try await client.deployments.get(id: firstDeployment.id)

        XCTAssertEqual(deployment.id, firstDeployment.id)
        XCTAssertEqual(deployment.url, firstDeployment.url)
        print("✅ Retrieved deployment: \(deployment.url)")
        print("   State: \(deployment.state.rawValue)")
        print("   Created: \(deployment.createdDate)")

        if let creator = deployment.creator {
            print("   Creator: \(creator.username ?? creator.uid)")
        }
    }

    func testFilterDeploymentsByState() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let readyDeployments = try await client.deployments.list(
            limit: 5,
            state: .ready
        )

        print("✅ Found \(readyDeployments.items.count) READY deployment(s)")

        for deployment in readyDeployments.items {
            XCTAssertEqual(deployment.state, .ready)
            print("  - \(deployment.url)")
        }
    }

    // MARK: - Domains Tests

    func testListDomains() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.domains.list(limit: 10)

        print("🌐 Found \(response.items.count) domain(s)")

        for domain in response.items {
            XCTAssertFalse(domain.name.isEmpty)
            let verified = domain.verified ?? false
            let status = verified ? "✅ verified" : "⏳ pending"
            print("  - \(domain.name) (\(status))")
        }
    }

    func testGetDNSRecords() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        let response = try await client.domains.list(limit: 1)
        guard let firstDomain = response.items.first else {
            throw XCTSkip("No domains available")
        }

        let records = try await client.domains.dnsRecords(domain: firstDomain.name)

        print("📝 Domain '\(firstDomain.name)' has \(records.count) DNS record(s)")

        for record in records {
            XCTAssertFalse(record.type.isEmpty)
            XCTAssertFalse(record.value.isEmpty)
            print("  - \(record.type) \(record.name) -> \(record.value)")
        }
    }

    // MARK: - Rate Limiting Tests

    func testRateLimitTracking() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        // Make a request
        _ = try await client.projects.list(limit: 1)

        // Check rate limit info
        if let rateLimit = await client.rateLimitInfo() {
            print("⏱️  Rate Limit Status:")
            print("   Limit: \(rateLimit.limit)")
            print("   Remaining: \(rateLimit.remaining)")
            print("   Resets at: \(rateLimit.resetAt)")

            XCTAssertGreaterThan(rateLimit.limit, 0)
            XCTAssertGreaterThanOrEqual(rateLimit.remaining, 0)
            XCTAssertLessThanOrEqual(rateLimit.remaining, rateLimit.limit)
        }
    }

    // MARK: - Error Handling Tests

    func testNotFoundError() async throws {
        guard let client = client else {
            throw XCTSkip("Integration tests disabled")
        }

        do {
            _ = try await client.deployments.get(id: "dpl_nonexistent_id_12345")
            XCTFail("Should have thrown notFound error")
        } catch VercelError.notFound(let resource) {
            print("✅ Correctly caught notFound error for: \(resource)")
            XCTAssertTrue(resource.contains("dpl_nonexistent_id_12345"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testInvalidAuthentication() async throws {
        // Create client with invalid token
        let invalidClient = VercelClient(token: "invalid_token_12345")

        do {
            _ = try await invalidClient.projects.list()
            XCTFail("Should have thrown authentication error")
        } catch VercelError.authenticationFailed(let message) {
            print("✅ Correctly caught authentication error: \(message)")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
