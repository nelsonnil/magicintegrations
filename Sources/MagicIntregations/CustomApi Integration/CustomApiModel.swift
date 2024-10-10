//
//  CustomApiModel.swift
//
//
//  Created by Jonas Socas on 24/11/23.
//

import Foundation

public struct CustomApiModel: Codable {
    public var url: String
    public var field: String
    public var currentPrediction: String
    public var count: Int

    public init(url: String, field: String, currentPrediction: String, count: Int) {
        self.url = url
        self.field = field
        self.currentPrediction = currentPrediction
        self.count = count
    }
}
