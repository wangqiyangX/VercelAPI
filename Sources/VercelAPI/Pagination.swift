import Foundation

/// Information about pagination state for list endpoints.
public struct PaginationInfo: Codable, Equatable, Sendable {
    /// Number of items in the current page.
    public let count: Int

    /// Timestamp for fetching the next page, or nil if this is the last page.
    public let next: Int64?

    /// Timestamp for fetching the previous page, or nil if this is the first page.
    public let prev: Int64?

    /// Whether there are more pages available.
    public var hasNextPage: Bool {
        next != nil
    }

    /// Whether there is a previous page available.
    public var hasPreviousPage: Bool {
        prev != nil
    }

    /// Date representation of the next page timestamp.
    public var nextDate: Date? {
        guard let next = next else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(next) / 1000.0)
    }

    /// Date representation of the previous page timestamp.
    public var previousDate: Date? {
        guard let prev = prev else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(prev) / 1000.0)
    }
}

/// A paginated response from the Vercel API.
public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    /// The items in the current page.
    public let items: [T]

    /// Pagination information.
    public let pagination: PaginationInfo

    /// Whether there are more pages available.
    public var hasNextPage: Bool {
        pagination.hasNextPage
    }

    /// Whether there is a previous page available.
    public var hasPreviousPage: Bool {
        pagination.hasPreviousPage
    }
}

/// Helper for iterating through all pages of a paginated endpoint.
public struct PaginatedIterator<T: Codable & Sendable>: AsyncSequence {
    public typealias Element = T

    private let fetchPage: (Int64?) async throws -> PaginatedResponse<T>

    init(fetchPage: @escaping (Int64?) async throws -> PaginatedResponse<T>) {
        self.fetchPage = fetchPage
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(fetchPage: fetchPage)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let fetchPage: (Int64?) async throws -> PaginatedResponse<T>
        private var currentPage: PaginatedResponse<T>?
        private var currentIndex = 0
        private var nextTimestamp: Int64?
        private var isFirstPage = true

        init(fetchPage: @escaping (Int64?) async throws -> PaginatedResponse<T>) {
            self.fetchPage = fetchPage
        }

        public mutating func next() async throws -> T? {
            // Fetch first page or next page if needed
            if currentPage == nil || currentIndex >= currentPage!.items.count {
                // If we've exhausted the current page and there's no next page, we're done
                if let page = currentPage, !page.hasNextPage {
                    return nil
                }

                // Fetch the next page
                let timestamp = isFirstPage ? nil : nextTimestamp
                isFirstPage = false

                currentPage = try await fetchPage(timestamp)
                currentIndex = 0
                nextTimestamp = currentPage?.pagination.next

                // If the new page is empty, we're done
                if currentPage?.items.isEmpty ?? true {
                    return nil
                }
            }

            // Return the next item from the current page
            guard let page = currentPage, currentIndex < page.items.count else {
                return nil
            }

            let item = page.items[currentIndex]
            currentIndex += 1
            return item
        }
    }
}
