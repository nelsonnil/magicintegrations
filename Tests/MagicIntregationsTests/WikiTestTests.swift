//
//  WikiTestTests.swift
//
//
//  Created by Jonas on 22/11/22.
//

import XCTest
@testable import MagicIntregations

final class WikiTestTests: XCTestCase {
    
    let wikiTestObservedObject = WikiTestObservedObject()
    
    override func setUp() async throws {
        WikiTestObservedObject.StorageKeys.wikitestURL = "Test"
        WikiTestObservedObject.StorageKeys.wikitestCount = 0
    }
    
    override class func tearDown() {
        WikiTestObservedObject.StorageKeys.removeObjects()
    }
    
    func testWikiTestDecodeDataFromURLcall() async {
        var dataResponse: String {
        """
        {
            "peek":"Coche",
            "modified":1,
            "image":""
        }
        """
        }
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(1, wikiTestObservedObject.wikitest?.modified)
        XCTAssertEqual("Coche", wikiTestObservedObject.wikitest?.peek)
    }
    
    func testWikiTestDecodeDataFromURLcallRaiseOnBadData() async {
        var dataResponse: String {
        """
        {
            "peek":"Coche",
            "modifiEd":1,
            "image":""
        }
        """
        }
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        var didFailWithError: Error?
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidDecodeResponse, didFailWithError as? ErrorsEnum)
    }
    
    func testLoadDataWithErrors() async throws {
        WikiTestObservedObject.StorageKeys.wikitestURL = ""
        var didFailWithError: Error?
        do {
            try await wikiTestObservedObject.load()
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidURL, didFailWithError as? ErrorsEnum)
        XCTAssertNil(wikiTestObservedObject.wikitest)
    }
    
    func testLoadedDataHaveNotChanged() async {
        var dataResponse1: String {
        """
        {
            "peek":"Coche",
            "modified":1,
            "image":""
        }
        """
        }
        
        let session = URLSessionMock(data: dataResponse1.data(using: .utf8))
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(1, wikiTestObservedObject.wikitest?.modified)
        XCTAssertEqual("Coche", wikiTestObservedObject.wikitest?.peek)
        
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertEqual(1, wikiTestObservedObject.wikitest?.modified)
        XCTAssertEqual("Coche", wikiTestObservedObject.wikitest?.peek)
    }
    
    func testLoadedDataHaveChanged() async {
        var dataResponse1: String {
        """
        {
            "peek":"Coche",
            "modified":1,
            "image":""
        }
        """
        }
        var dataResponse2: String {
        """
        {
            "peek":"Ferrari",
            "modified":2,
            "image":""
        }
        """
        }
        
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        do {
            try await wikiTestObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(1, wikiTestObservedObject.wikitest?.modified)
        XCTAssertEqual("Coche", wikiTestObservedObject.wikitest?.peek)
        do {
            try await wikiTestObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(2, wikiTestObservedObject.wikitest?.modified)
        XCTAssertEqual("Ferrari", wikiTestObservedObject.wikitest?.peek)
    }
    
    func testAfterResetWithNotChangeInjectShouldBeNill() async {
        var dataResponse: String {
        """
        {
            "peek":"Coche",
            "modified":1,
            "image":""
        }
        """
        }
        
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        
        XCTAssertNil(wikiTestObservedObject.wikitest)
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(wikiTestObservedObject.wikitest)
        wikiTestObservedObject.reset()
        do {
            try await wikiTestObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNil(wikiTestObservedObject.wikitest)
    }
    
    func testAfterResetWithChangeInjectShouldNotBeNill() async {
        var dataResponse1: String {
        """
        {
            "peek":"Coche",
            "modified":1,
            "image":""
        }
        """
        }
        var dataResponse2: String {
        """
        {
            "peek":"Ferrari",
            "modified":2,
            "image":""
        }
        """
        }
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        XCTAssertNil(wikiTestObservedObject.wikitest)
        do {
            try await wikiTestObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(wikiTestObservedObject.wikitest)
        
        wikiTestObservedObject.reset()
        XCTAssertNil(wikiTestObservedObject.wikitest)
        
        do {
            try await wikiTestObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(wikiTestObservedObject.wikitest)
    }
}
