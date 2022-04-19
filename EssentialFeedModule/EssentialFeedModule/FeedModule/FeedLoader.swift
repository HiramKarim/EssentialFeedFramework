//
//  FeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 07/02/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
