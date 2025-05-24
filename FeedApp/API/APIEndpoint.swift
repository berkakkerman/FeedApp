//
//  APIEndpoint.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

enum APIEndpoint {
    case posts(PostQuery)

    var url: URL? {
        var components = URLComponents(string: "https://6831c8df6205ab0d6c3d9c56.mockapi.io/posts")
        switch self {
        case .posts(let query):
            components?.queryItems = query.queryItems
        }
        return components?.url
    }
}
