//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedModuleTests
//
//  Created by Hiram Castro on 16/02/22.
//

import XCTest
import EssentialFeedModule

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_ , client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        let clientError = NSError(domain: "Test", code: 0)
        
        sut.load { error in
            capturedErrors.append(error)
        }
        
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.completions.append(completion)
            self.requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
    
}
