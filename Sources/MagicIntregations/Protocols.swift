//
//  Protocols.swift
//
//
//  Created by Jonás - HORICAN on 30/12/23.
//

import Foundation

public protocol URLSessionProtocol {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
