//
//  Post.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

struct Post: Hashable, Decodable {
    let id: String
    let title: String?
    let imageUrl: String?
    let createdAtDate: Date?
    let createdAtString: String?

    enum CodingKeys: String, CodingKey {
        case id, title, imageUrl, createdAtDate
        case createdAtString = "createdAt"
    }
}
