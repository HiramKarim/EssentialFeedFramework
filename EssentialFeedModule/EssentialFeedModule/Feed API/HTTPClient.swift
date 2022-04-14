//
//  HTTPClient.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 13/04/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
