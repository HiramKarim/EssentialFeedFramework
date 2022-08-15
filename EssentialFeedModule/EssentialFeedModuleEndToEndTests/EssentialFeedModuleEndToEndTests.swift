//
//  EssentialFeedModuleEndToEndTests.swift
//  EssentialFeedModuleEndToEndTests
//
//  Created by Hiram Castro on 15/08/22.
//

import XCTest
import EssentialFeedModule

class EssentialFeedModuleEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGetFeedResult_matchesFixedTestAccountData() {
        let testServrURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServrURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadFeedResult?
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items")
        case let .failure(error)?:
            XCTFail("expected success, got \(error) instead")
        default:
            XCTFail("Expected success")
        }
    }

}
