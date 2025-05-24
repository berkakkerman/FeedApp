//
//  FeedService.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import RealmSwift
import Foundation

actor FeedService {
    static let shared = FeedService()
    private let pageSize = 20

    func loadCachedPosts() -> [Post] {
        do {
            let realm = try Realm()
            let objects = realm.objects(PostObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
            
            return objects.compactMap { obj in
                Post(
                    id: obj.id,
                    title: obj.title,
                    imageUrl: obj.imageUrl,
                    createdAtDate: obj.createdAt,
                    createdAtString: ISO8601DateFormatter().string(from: obj.createdAt)
                )
            }
        } catch {
            print("Realm init error:", error)
            return []
        }
    }

    func saveToCache(_ posts: [Post]) {
        do {
            let realm = try Realm()
            let objs = posts.compactMap { PostObject(from: $0) }
            try realm.write {
                realm.add(objs, update: .modified)
            }
        } catch {
            print("Realm write error:", error)
        }
    }

    func fetchPosts(afterCreatedAt: String?) async throws -> [Post] {
        let query = PostQuery(limit: pageSize, afterCreatedAt: afterCreatedAt)
        return try await APIClient.shared.get(.posts(query))
    }
}
