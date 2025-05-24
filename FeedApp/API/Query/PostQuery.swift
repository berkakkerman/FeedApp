//
//  PostQuery.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

struct PostQuery: QueryParametersConvertible {
    let limit: Int
    let afterCreatedAt: String?

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: QueryKey.limit.rawValue,
                  value: "\(limit)"),
            .init(name: QueryKey.sortBy.rawValue,
                  value: QueryValue.sortByCreatedAt),
            .init(name: QueryKey.order.rawValue,
                  value: QueryValue.orderDesc)
        ]
        if let after = afterCreatedAt {
            items.append(.init(name: QueryKey.createdAtLt.rawValue,
                               value: after))
        }
        return items
    }
}
