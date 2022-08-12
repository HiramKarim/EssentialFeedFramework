//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedModuleTests
//
//  Created by Hiram Castro on 28/04/22.
//

import XCTest
import EssentialFeedModule

//protocol HTTPSession {
//    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
//}
//
//protocol HTTPSessionTask {
//    func resume()
//}



class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation:Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = makeURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllRepresentationCases() {
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual(receivedError as NSError?, requestError)
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: makeUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: makeHTTPUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: makeAnyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: makeAnyData(), response: nil, error: makeAnyError()))
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: makeUrlResponse(), error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: makeHTTPUrlResponse(), error: makeAnyError()))
        
        XCTAssertNotNil(resultErrorFor(data: makeAnyData(), response: makeUrlResponse(), error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: makeAnyData(), response: makeHTTPUrlResponse(), error: makeAnyError()))
        XCTAssertNotNil(resultErrorFor(data: makeAnyData(), response: makeUrlResponse(), error: nil))
    }
    
    func test_getFromURL_failsOnAllNilError() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData(file: StaticString = #file, line: UInt = #line) {
        let data = makeAnyData()
        let response = makeHTTPUrlResponse() // given
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil) // when
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode) // then
    }
    
    func test_getFromURL_suceedsWithEmptyHTTPURLResponseWithNilData(file: StaticString = #file, line: UInt = #line) {
        let response = makeHTTPUrlResponse() // given
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil) // when
        
        XCTAssertEqual(receivedValues?.data, Data())
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode) // then
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data:Data?, response:URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
            switch result {
             case let .failure(error):
                return error
            default:
                XCTFail("expected failure, got \(result) indetad", file:file, line:line)
                return nil
        }
    }
    
    private func resultValuesFor(data:Data?,
                                 response:URLResponse?,
                                 error:Error?,
                                 file: StaticString = #file,
                                 line: UInt = #line) -> (data:Data, response:HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
         case let .success(data, response):
            return (data, response)
        default:
            XCTFail("expected success, got \(result) indetad", file:file, line:line)
            return nil
        }
    }
    
    private func resultFor(data:Data?,
                           response:URLResponse?,
                           error:Error?,
                           file: StaticString = #file,
                           line: UInt = #line) -> HTTPClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var receivedResult:HTTPClientResult!
        
        let exp = expectation(description: "wait for completion")
        let sut = makeSUT(file:file, line:line)
        
        sut.get(from: makeURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private func makeURL() -> URL {
        return URL(string: "http:any-url.com")!
    }
    
    private func makeAnyData() -> Data {
        return Data("some data".utf8)
    }
    
    private func makeAnyError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
    
    private func makeUrlResponse() -> URLResponse {
        return URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeHTTPUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub:Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data:Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data:data, response:response, error: error)
        }
        
        static func observeRequests(observer: @escaping(URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
    }
    
}
