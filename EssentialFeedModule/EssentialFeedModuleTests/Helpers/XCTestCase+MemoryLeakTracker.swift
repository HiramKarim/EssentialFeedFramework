//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialFeedModuleTests
//
//  Created by Hiram Castro on 08/08/22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file:file, line: line)
        }
    }
}
