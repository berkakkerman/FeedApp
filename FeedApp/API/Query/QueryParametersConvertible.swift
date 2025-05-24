//
//  QueryParametersConvertible.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import Foundation

protocol QueryParametersConvertible {
    var queryItems: [URLQueryItem] { get }
}
