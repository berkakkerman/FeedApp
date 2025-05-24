//
//  FeedViewModel.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

actor FeedViewModel {
    private let service = FeedService.shared
    private let pageSize = 20

    private var posts: [Post] = []
    private var lastCreatedAt: String? = nil
    private var isLoading = false
    private var newCount: Int = .zero

    private var stream: AsyncStream<FeedEvent>.Continuation?

    /// Returns an AsyncStream of feed events that the UI can observe.
    /// - Returns: An AsyncStream emitting FeedEvent updates for posts, loading state, and new post count.
    func events() -> AsyncStream<FeedEvent> {
        AsyncStream { continuation in
            stream = continuation
            continuation.yield(.postsUpdated(posts))
            continuation.yield(.loading(isLoading))
            continuation.yield(.newCount(newCount))
        }
    }

    /// Sends a FeedEvent to the active stream listeners.
    /// - Parameter event: The FeedEvent to send through the stream.
    private func send(_ event: FeedEvent) {
        stream?.yield(event)
    }

    /// Executes an asynchronous operation while managing loading state and emitting loading events.
    /// - Parameter operation: A closure that performs async work on the FeedViewModel.
    private func withLoading(_ operation: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        send(.loading(true))

        do {
            try await operation()
        } catch {
            send(.error(error.localizedDescription))
        }

        isLoading = false
        send(.loading(false))
    }

    /// Updates the lastCreatedAt property based on the current posts array.
    private func updateLastCreatedAt() {
        // Assumes posts are sorted descending by createdAt (newest first)
        lastCreatedAt = posts.last?.createdAtString
    }

    /// Loads initial posts from cache, updates the UI, then fetches fresh posts from the server.
    func loadInitial() async {
        await withLoading {
            let cached = await service.loadCachedPosts()
            posts = cached.map { item in
                Post(
                    id: item.id,
                    title: item.title,
                    imageUrl: item.imageUrl,
                    createdAtDate: item.createdAtDate,
                    createdAtString: ISO8601DateFormatter().string(from: item.createdAtDate ?? Date())
                )
            }
            updateLastCreatedAt()
            send(.postsUpdated(posts))

            let fresh = try await service.fetchPosts(afterCreatedAt: lastCreatedAt)
            if !fresh.isEmpty {
                posts = fresh
                updateLastCreatedAt()
                await service.saveToCache(fresh)
                send(.postsUpdated(posts))
            }

            await checkNewPosts()
        }
    }

    /// Loads additional posts after the current lastCreatedAt and appends them to the feed.
    func loadMore() async {
        await withLoading {
            let more = try await service.fetchPosts(afterCreatedAt: lastCreatedAt)
            if !more.isEmpty {
                posts.append(contentsOf: more)
                updateLastCreatedAt()
                await service.saveToCache(more)
                send(.postsUpdated(posts))
            }

            await checkNewPosts()
        }
    }

    /// Checks for new posts and updates the newCount property.
    func checkNewPosts() async {
        do {
            let fresh = try await service.fetchPosts(afterCreatedAt: nil)
            let count = max(.zero, fresh.count - posts.count)
            newCount = count
            send(.newCount(count))
        } catch {
            send(.error(error.localizedDescription))
        }
    }

    /// Inserts newly fetched posts at the top of the feed if available.
    func insertNew() async {
        guard newCount > .zero else { return }
        await withLoading {
            let fresh = try await service.fetchPosts(afterCreatedAt: nil)
            posts.insert(contentsOf: fresh.prefix(newCount), at: .zero)
            updateLastCreatedAt()
            await service.saveToCache(Array(fresh.prefix(newCount)))
            newCount = .zero
            send(.newCount(.zero))
            send(.postsUpdated(posts))
        }
    }
}
