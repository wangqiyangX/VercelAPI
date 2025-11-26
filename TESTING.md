# Running Integration Tests

The VercelAPI package includes comprehensive integration tests that make real API calls to Vercel. These tests are **skipped by default** to avoid requiring API credentials for basic unit testing.

## Test Coverage

### Unit Tests (Always Run)
- ✅ Error handling and descriptions
- ✅ Pagination logic
- ✅ Model enums and types
- ✅ Rate limiter functionality

**Total: 15 unit tests**

### Integration Tests (Optional)
- Teams API (list teams, get members)
- Projects API (list, get, pagination, environment variables)
- Deployments API (list, get, filter by state)
- Domains API (list, DNS records)
- Rate limiting tracking
- Error handling (404, authentication)

**Total: 13 integration tests**

## Running Tests

### Run Unit Tests Only (Default)

```bash
swift test
```

This runs all unit tests and skips integration tests. You'll see output like:

```
⏭️  Skipping integration tests - set VERCEL_API_TOKEN to enable
Executed 28 tests, with 13 tests skipped and 0 failures
```

### Run Integration Tests

1. **Create a Vercel API Token**
   - Go to https://vercel.com/account/tokens
   - Click "Create Token"
   - Give it a descriptive name (e.g., "VercelAPI Integration Tests")
   - Select scope (personal or team)
   - Copy the token

2. **Set Environment Variable**

   ```bash
   export VERCEL_API_TOKEN="your_token_here"
   ```

3. **Run Tests**

   ```bash
   swift test
   ```

   You'll see output like:

   ```
   ✅ Integration tests enabled with API token
   📋 Found 2 team(s)
     - My Team (my-team)
   📦 Found 5 project(s)
     - my-app [nextjs]
     - another-project [vite]
   🚀 Found 10 deployment(s)
   ...
   Executed 28 tests, with 0 tests skipped and 0 failures
   ```

## Integration Test Details

### Teams Tests
- `testListTeams()` - Lists all teams for the authenticated user
- `testGetTeamMembers()` - Retrieves members of the first team

### Projects Tests
- `testListProjects()` - Lists first 10 projects
- `testListAllProjectsWithPagination()` - Tests AsyncSequence pagination (limited to 15 projects)
- `testGetProject()` - Retrieves details of a specific project
- `testGetEnvironmentVariables()` - Lists environment variables for a project

### Deployments Tests
- `testListDeployments()` - Lists first 10 deployments
- `testGetDeployment()` - Retrieves details of a specific deployment
- `testFilterDeploymentsByState()` - Filters deployments by READY state

### Domains Tests
- `testListDomains()` - Lists all domains
- `testGetDNSRecords()` - Retrieves DNS records for a domain

### Rate Limiting Tests
- `testRateLimitTracking()` - Verifies rate limit headers are tracked

### Error Handling Tests
- `testNotFoundError()` - Tests 404 error handling
- `testInvalidAuthentication()` - Tests authentication error handling

## Important Notes

⚠️ **Read-Only Tests**: All integration tests are read-only and won't modify your Vercel account. They only:
- List existing resources
- Retrieve details of existing resources
- Test error conditions with invalid IDs

✅ **Safe to Run**: These tests won't create, update, or delete any resources in your Vercel account.

⏱️ **Test Duration**: Integration tests take ~2-3 seconds to complete (depending on network speed and API response time).

🔒 **Security**: Never commit your API token to version control. Use environment variables only.

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Unit Tests
        run: swift test
      
      - name: Run Integration Tests
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        env:
          VERCEL_API_TOKEN: ${{ secrets.VERCEL_API_TOKEN }}
        run: swift test
```

### GitLab CI Example

```yaml
test:
  script:
    - swift test
  variables:
    VERCEL_API_TOKEN: $VERCEL_API_TOKEN
  only:
    - main
```

## Troubleshooting

### Tests Are Skipped

**Problem**: All integration tests show as skipped

**Solution**: Make sure `VERCEL_API_TOKEN` environment variable is set:

```bash
echo $VERCEL_API_TOKEN  # Should print your token
```

### Authentication Failed

**Problem**: Tests fail with authentication error

**Solutions**:
1. Verify your token is valid at https://vercel.com/account/tokens
2. Check token hasn't expired
3. Ensure token has correct scope (personal or team)

### No Resources Found

**Problem**: Tests skip because no projects/deployments/domains exist

**Solution**: This is expected if your Vercel account is empty. The tests will skip gracefully with messages like "No projects available for testing".

### Rate Limit Exceeded

**Problem**: Tests fail with rate limit error

**Solution**: Wait for the rate limit to reset (check the reset time in the error message) or reduce the number of tests running.

## Test Output Examples

### Successful Run

```
Test Suite 'IntegrationTests' started
⏭️  Skipping integration tests - set VERCEL_API_TOKEN to enable
Test Suite 'IntegrationTests' passed
         Executed 13 tests, with 13 tests skipped
```

### With API Token

```
Test Suite 'IntegrationTests' started
✅ Integration tests enabled with API token
📋 Found 2 team(s)
  - Personal Account (personal)
  - Work Team (work-team)
👥 Team 'Personal Account' has 1 member(s)
  - John Doe (OWNER)
📦 Found 5 project(s)
  - my-nextjs-app [nextjs]
  - portfolio [vite]
  - blog [gatsby]
✅ Retrieved project: my-nextjs-app
   Framework: nextjs
   Build command: npm run build
🔐 Project 'my-nextjs-app' has 3 environment variable(s)
  - DATABASE_URL [targets: production]
  - API_KEY [targets: development, preview]
🚀 Found 10 deployment(s)
  - my-nextjs-app (READY) - my-app-xyz.vercel.app
✅ Retrieved deployment: my-app-xyz.vercel.app
   State: READY
   Created: 2025-11-26 08:15:30 +0000
⏱️  Rate Limit Status:
   Limit: 100
   Remaining: 95
   Resets at: 2025-11-26 09:00:00 +0000
✅ Correctly caught notFound error for: /v13/deployments/dpl_nonexistent_id_12345
✅ Correctly caught authentication error: Forbidden
Test Suite 'IntegrationTests' passed
         Executed 13 tests, with 0 failures
```

## Contributing

When adding new integration tests:

1. **Use XCTSkip**: Always check for API token and skip if not available
2. **Be Read-Only**: Don't create/modify/delete resources
3. **Handle Empty Accounts**: Skip gracefully if no resources exist
4. **Add Logging**: Print useful information for debugging
5. **Test Error Cases**: Include tests for expected failures
