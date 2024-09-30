//
//  CustomApiTest.swift
//
//
//  Created by Jonas on 19/11/22.
//

import XCTest
@testable import MagicIntregations

final class CustomApiTests: XCTestCase {
    
    let fileName = "customApi1"
    
    let customApiObservedObject = CustomApiObservedObject(fileName: "customApi1")
    
    override func setUp() async throws {
        let customApiModel = CustomApiModel(url: "TEST", field: "song", currentPrediction: "")
        customApiObservedObject.customApiModel = customApiModel
    }
    
    override func tearDown() {
        customApiObservedObject.removeJsonFile()
    }
    
    func testCreateJsonDocument() throws {
        let filePath = FileManager.default.documentsDirectory.appendingPathComponent(fileName, conformingTo: .json).path
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath))
    }
    
    func testCustomApiModelIsNotNil() {
        XCTAssertNotNil(customApiObservedObject.customApiModel)
    }
    
    func testCustomApiModelHasCertainValues() {
        XCTAssertEqual("TEST", customApiObservedObject.customApiModel?.url)
        customApiObservedObject.customApiModel = CustomApiModel(url:"www.google.es", field: "value", currentPrediction: "")
        XCTAssertEqual("www.google.es", customApiObservedObject.customApiModel?.url)
        customApiObservedObject.customApiModel = nil
        customApiObservedObject.loadJsonFile()
        XCTAssertEqual("www.google.es", customApiObservedObject.customApiModel?.url)
    }
    
    func testCustomApiDecodeDataFromURLcall() async {
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
            try await customApiObservedObject.load(urlSession: session)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.customApiModel?.currentPrediction)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.prediction)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCustomApiDecodeDataFromURLcallRaiseOnBadData() async {
        var dataResponse: String {
        """
        {
            "count": 49,
            "datetime": "2022-10-18 20:21:11",
            "url": "https://genius.com/songs/2414729",
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
        var didFailWithError:Error?
        
        do {
            try await customApiObservedObject.load(urlSession: session)
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidDecodeResponse, didFailWithError as? ErrorsEnum)
        
        XCTAssertNil(customApiObservedObject.prediction)
    }
    
    func testLoadDataWithErrors() async throws {
        customApiObservedObject.customApiModel?.url = ""
        var didFailWithError: Error?
        do {
            try await customApiObservedObject.load()
        } catch {
            didFailWithError = error
        }
        XCTAssertEqual(ErrorsEnum.invalidURL, didFailWithError as? ErrorsEnum)
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
            try await customApiObservedObject.load(urlSession: session)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.customApiModel?.currentPrediction)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.prediction)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            try await customApiObservedObject.load(urlSession: session)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.customApiModel?.currentPrediction)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.prediction)
        } catch {
            XCTFail(error.localizedDescription)
        }
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
                "count": 49,
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
                "outputWords": "outputWords49",
                "wordToNumber": ""
              }
            """
        }
        
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        do {
            try await customApiObservedObject.load(urlSession: session1)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.customApiModel?.currentPrediction)
            XCTAssertEqual("Ella y Yo", customApiObservedObject.prediction)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            try await customApiObservedObject.load(urlSession: session2)
            XCTAssertEqual("Yesterday", customApiObservedObject.customApiModel?.currentPrediction)
            XCTAssertEqual("Yesterday", customApiObservedObject.prediction)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAfterResetWithNotChangeInjectShouldBeNill() async {
        let dataResponse = """
            {
                "count":1,
                "song":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session = URLSessionMock(data: dataResponse.data(using: .utf8))
        
        XCTAssertNil(customApiObservedObject.prediction)
        do {
            try await customApiObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(customApiObservedObject.prediction)
        customApiObservedObject.reset()
        do {
            try await customApiObservedObject.load(urlSession: session)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNil(customApiObservedObject.prediction)
    }
    
    func testAfterResetWithChangeInjectShouldNotBeNill() async {
        let dataResponse1 = """
            {
                "count":1,
                "song":"andres",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let dataResponse2 = """
            {
                "count":2,
                "song":"andresita",
                "receiveCount":172,
                "source":"google",
                "thumperId":null
            }
            """
        let session1 = URLSessionMock(data: dataResponse1.data(using: .utf8))
        let session2 = URLSessionMock(data: dataResponse2.data(using: .utf8))
        
        XCTAssertNil(customApiObservedObject.prediction)
        do {
            try await customApiObservedObject.load(urlSession: session1)
        } catch {
            XCTFail(error.localizedDescription)
        }
        XCTAssertNotNil(customApiObservedObject.prediction)
        
        customApiObservedObject.reset()
        XCTAssertNil(customApiObservedObject.prediction)
        
        do {
            try await customApiObservedObject.load(urlSession: session2)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        XCTAssertNotNil(customApiObservedObject.prediction)
    }
}
