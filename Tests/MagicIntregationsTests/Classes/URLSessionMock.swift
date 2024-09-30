//
//  URLSessionMock.swift
//
//
//  Created by Jonás - HORICAN on 30/12/23.
//

import SwiftUI
import MagicIntregations

class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var error: Error?
    
    init(data: Data? = nil, error: Error? = nil) {
        self.data = data
        self.error = error
    }
    
    func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        if let data = data {
            print("return")
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        } else if let error = error {
            throw error
        } else {
            throw ErrorsEnum.invalidDecodeResponse
        }
    }
}
