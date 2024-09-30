//
//  InjectModel.swift
//  
//
//  Created by Jonas on 19/11/22.
//

import Foundation

public struct InjectModel: Decodable {
    public let count: Int
    public let value: String
    public let receiveCount: Int?
    public let source: String?
    public let thumperId: Int?
}
