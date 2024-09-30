//
//  InjectTests.swift
//  
//
//  Created by Jonas on 22/11/22.
//

import XCTest
@testable import MagicIntregations

final class InjectTests: XCTestCase {
    
    let injectObservedObject: InjectObservedObject = InjectObservedObject()
    
    override func setUp() async throws {
        InjectObservedObject.StorageKeys.injectURL = "Test"
        InjectObservedObject.StorageKeys.injectCount = 0
    }
    
    override func tearDown() {
        InjectObservedObject.StorageKeys.removeObjects()
    }
    
    func testInjectDecodeDataFromURLcall() async throws {
        let dataResponse = """
            {
                "count":1,
                "value":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        try await injectObservedObject.load(urlSession: session)
        XCTAssertEqual(1, injectObservedObject.inject?.count)
        XCTAssertEqual("andres", injectObservedObject.inject?.value)
    }
    
    func testInjectDecodeDataFromURLcallRaiseOnBadData() async throws {
        let dataResponse = """
            {
                "count":1,
                "values":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        var didFailWithError: ErrorsEnum?
        do {
            try await injectObservedObject.load(urlSession: session)
        } catch {
            didFailWithError = error as? ErrorsEnum
        }
        XCTAssertEqual(ErrorsEnum.invalidDecodeResponse, didFailWithError)
    }
    
    func testLoadDataWithErrors() async throws {
        InjectObservedObject.StorageKeys.injectURL = ""
        var didFailWithErrror: Error?
        do {
            try await injectObservedObject.load()
        } catch {
            didFailWithErrror = error
        }
        XCTAssertEqual(ErrorsEnum.invalidURL, didFailWithErrror as? ErrorsEnum)
        XCTAssertNil(injectObservedObject.inject)
    }
    
    func testLoadedDataHaveNotChanged() async {
        var dataResponse1: String {
        """
        {
            "count":1,
            "value":"andres",
            "receiveCount":172,
            "source":"google",
            "thumperId":null
        }
        """
        }
        
        let session = URLSessionMock(data: dataResponse1.data(using: .utf8))
        do {
            try await injectObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(1, injectObservedObject.inject?.count)
        XCTAssertEqual("andres", injectObservedObject.inject?.value)
        
        do {
            try await injectObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(1, injectObservedObject.inject?.count)
        XCTAssertEqual("andres", injectObservedObject.inject?.value)
    }
    
    func testLoadedDataHaveChanged() async {
        var dataResponse1: String {
        """
        {
            "count":1,
            "value":"andres",
            "receiveCount":172,
            "source":"google",
            "thumperId":null
        }
        """
        }
        var dataResponse2: String {
        """
        {
            "count":2,
            "value":"pepe",
            "receiveCount":172,
            "source":"google",
            "thumperId":null
        }
        """
        }
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        do {
            try await injectObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(1, injectObservedObject.inject?.count)
        XCTAssertEqual("andres", injectObservedObject.inject?.value)
        do {
            try await injectObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(2, injectObservedObject.inject?.count)
        XCTAssertEqual("pepe", injectObservedObject.inject?.value)
    }
    
    func testAfterResetWithNotChangeInjectShouldBeNill() async {
        let dataResponse = """
            {
                "count":1,
                "value":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        
        XCTAssertNil(injectObservedObject.inject)
        do {
            try await injectObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(injectObservedObject.inject)
        injectObservedObject.reset()
        do {
            try await injectObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNil(injectObservedObject.inject)
    }
    
    func testAfterResetWithChangeInjectShouldNotBeNill() async {
        let dataResponse1 = """
            {
                "count":1,
                "value":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let dataResponse2 = """
            {
                "count":2,
                "value":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        XCTAssertNil(injectObservedObject.inject)
        do {
            try await injectObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(injectObservedObject.inject)
        
        injectObservedObject.reset()
        XCTAssertNil(injectObservedObject.inject)
        
        do {
            try await injectObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(injectObservedObject.inject)
    }
}
