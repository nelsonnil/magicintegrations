//
//  ErrorsEnum.swift
//  
//
//  Created by Jonas on 19/11/22.
//

import Foundation

public enum ErrorsEnum: Error, Equatable, LocalizedError {
    case invalidURL
    case badDataResponse
    case invalidDecodeResponse
    case errorLoadingObject
}
