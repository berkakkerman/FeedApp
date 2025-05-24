//
//  PostObject.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation
import RealmSwift

final class PostObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageUrl: String? = nil
    @objc dynamic var createdAt: Date = Date()

    override static func primaryKey() -> String? { "id" }

    convenience init(from post: Post) {
        self.init()
        id = post.id
        title = post.title ?? ""
        imageUrl = post.imageUrl
        
        if let dateString = post.createdAtString, let date = ISO8601DateFormatter().date(from: dateString) {
            createdAt = date
        }
    }
}
