//
//  ElipsTests.swift
//  
//
//  Created by Jonas on 19/11/22.
//

import XCTest
@testable import MagicIntregations

final class ElipsTests: XCTestCase {
    
    let elipsObservedObject = ElipsObservedObject()
    
    override func setUp() async throws {
        ElipsObservedObject.StorageKeys.elipsURL = "Test"
        ElipsObservedObject.StorageKeys.elipsCount = 0
    }
    
    override class func tearDown() {
        ElipsObservedObject.StorageKeys.removeObjects()
    }
    
    func testElipsDecodeDataFromURLcall() async {
        var dataResponse: String {
        """
        {
            "count": 49,
            "datetime": "2022-10-18 20:21:11",
            "url": "https://genius.com/songs/2414729",
            "song": "Ella y Yo",
            "artist": "Pepe Quintana",
            "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
            "minimumNumberOfLetters": "6",
            "currentStep": "LLAMANDO, MALDONADO",
            "stepIfYes": "",
            "stepIfNo": "",
            "globalStep": "LLAMANDO, MALDONADO",
            "outputWords": "outputWords49",
            "wordToNumber": ""
          }
        """
        }
        
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(49, elipsObservedObject.elips?.count)
        XCTAssertEqual("Ella y Yo", elipsObservedObject.elips?.song)
        XCTAssertEqual("outputWords49", elipsObservedObject.elips?.outputWords)
    }
    
    func testElipsDecodeDataFromURLcallRaiseOnBadData() async {
        
        var dataResponse: String {
        """
        {
            "count": 49,
            "datetime": "2022-10-18 20:21:11",
            "url": "https://genius.com/songs/2414729",
            "song": "Ella y Yo",
            "art_ist": "Pepe Quintana",
            "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
            "minimumNumberOfLetters": "6",
            "currentStep": "LLAMANDO, MALDONADO",
            "stepIfYes": "",
            "stepIfNo": "",
            "globalStep": "LLAMANDO, MALDONADO",
            "outputWords": "outputWords49",
            "wordToNumber": ""
          }
        """
        }
        
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        var didFailWithError: Error?
        
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidDecodeResponse, didFailWithError as? ErrorsEnum)
        XCTAssertNil(elipsObservedObject.elips)
    }
    
    func testLoadDataWithErrors() async throws {
        ElipsObservedObject.StorageKeys.elipsURL = ""
        var didFailWithError: Error?
        do {
            try await elipsObservedObject.load()
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidURL, didFailWithError as? ErrorsEnum)
        XCTAssertNil(elipsObservedObject.elips)
    }
    
    func testLoadedDataHaveNotChanged() async {
        var dataResponse: String {
            """
            {
                "count": 49,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Ella y Yo",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords49",
                "wordToNumber": ""
              }
            """
        }
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(49, elipsObservedObject.elips?.count)
        XCTAssertEqual("Ella y Yo", elipsObservedObject.elips?.song)
        XCTAssertEqual("outputWords49", elipsObservedObject.elips?.outputWords)
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(49, elipsObservedObject.elips?.count)
        XCTAssertEqual("Ella y Yo", elipsObservedObject.elips?.song)
        XCTAssertEqual("outputWords49", elipsObservedObject.elips?.outputWords)
    }
    
    func testLoadedDataHaveChanged() async {
        var dataResponse1: String {
            """
            {
                "count": 49,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Ella y Yo",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords49",
                "wordToNumber": ""
              }
            """
        }
        var dataResponse2: String {
            """
            {
                "count": 50,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Yesterday",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords50",
                "wordToNumber": ""
              }
            """
        }
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        do {
            try await elipsObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(49, elipsObservedObject.elips?.count)
        XCTAssertEqual("Ella y Yo", elipsObservedObject.elips?.song)
        XCTAssertEqual("outputWords49", elipsObservedObject.elips?.outputWords)
        do {
            try await elipsObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertEqual(50, elipsObservedObject.elips?.count)
        XCTAssertEqual("Yesterday", elipsObservedObject.elips?.song)
        XCTAssertEqual("outputWords50", elipsObservedObject.elips?.outputWords)
    }
    
    func testAfterResetWithNotChangeInjectShouldBeNill() async {
        var dataResponse: String {
            """
            {
                "count": 49,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Ella y Yo",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords49",
                "wordToNumber": ""
              }
            """
        }

        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        
        XCTAssertNil(elipsObservedObject.elips)
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(elipsObservedObject.elips)
        elipsObservedObject.reset()
        do {
            try await elipsObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNil(elipsObservedObject.elips)
    }
    
    func testAfterResetWithChangeInjectShouldNotBeNill() async {
        var dataResponse1: String {
            """
            {
                "count": 49,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Ella y Yo",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords49",
                "wordToNumber": ""
              }
            """
        }
        var dataResponse2: String {
            """
            {
                "count": 50,
                "datetime": "2022-10-18 20:21:11",
                "url": "https://genius.com/songs/2414729",
                "song": "Yesterday",
                "artist": "Pepe Quintana",
                "cover": "https://images.genius.com/8770889cc623c212cdcb73f11712be35.300x300x1.png",
                "minimumNumberOfLetters": "6",
                "currentStep": "LLAMANDO, MALDONADO",
                "stepIfYes": "",
                "stepIfNo": "",
                "globalStep": "LLAMANDO, MALDONADO",
                "outputWords": "outputWords50",
                "wordToNumber": ""
              }
            """
        }
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        XCTAssertNil(elipsObservedObject.elips)
        do {
            try await elipsObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(elipsObservedObject.elips)
        
        elipsObservedObject.reset()
        XCTAssertNil(elipsObservedObject.elips)
        
        do {
            try await elipsObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(elipsObservedObject.elips)
    }
}
