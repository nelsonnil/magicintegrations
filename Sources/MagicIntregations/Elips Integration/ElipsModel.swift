//
//  ElipsModel.swift
//  
//
//  Created by Jonas on 19/11/22.
//

import Foundation

public struct ElipsModel: Decodable, Equatable {
    public let count: Int
    public let datetime: String
    public let url: String
    public let song, artist: String
    public let cover: String
    public let minimumNumberOfLetters, currentStep, stepIfYes, stepIfNo: String
    public let globalStep, outputWords, wordToNumber: String
}
