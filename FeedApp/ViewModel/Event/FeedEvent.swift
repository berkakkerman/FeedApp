//
//  FeedEvent.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

enum FeedEvent {
    case postsUpdated([Post])
    case loading(Bool)
    case newCount(Int)
    case error(String)
}

