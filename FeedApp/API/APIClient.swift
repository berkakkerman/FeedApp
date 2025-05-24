//
//  APIClient.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
       
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[APIClient] Response JSON for \(endpoint):\n\(jsonString)")
        } else {
            print("[APIClient] ⚠️ Couldn't decode response data as UTF-8 string")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("[APIClient] ⚠️ URL: \(url.absoluteString)")
            throw APIError.decodingFailed
        }
    }
}
