//
//  FeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 07/02/22.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable { }

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
