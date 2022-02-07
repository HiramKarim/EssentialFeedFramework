//
//  FeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 07/02/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
