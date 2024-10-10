//
//  CustomApiObservedObject.swift
//  
//
//  Created by Jonas on 01/10/23.
//

import Foundation
import SwiftUI

final public class CustomApiObservedObject: ObservableObject {
    
    @Published public private(set) var prediction: String?
    public var customApiModel: CustomApiModel? {
        didSet {
            if let fileUrl, let customApiModel {
                let jsonEnconder = JSONEncoder()
                do {
                    let jsonData = try jsonEnconder.encode(customApiModel)
                    try jsonData.write(to: fileUrl, options: [.atomic])
                } catch {
                    print(error)
                }
            }
        }
    }
    
    public static let SectionCaption: String = "Paste you Custom API URL that grant access to third party applications and the field you want to observe"
    public static let FieldCaption: String = "e.g., https://api.com/endpoint"
    private var fileName: String
    private var fileUrl: URL?
    
    public init(fileName: String) {
        self.fileName = fileName
        self.fileUrl = FileManager.default.documentsDirectory.appendingPathComponent(fileName, conformingTo: .json)
        loadJsonFile()
    }

    public struct StorageKeys {
        static public var customAPICount: Int {
            get {
                UserDefaults.standard.integer(forKey: "customCount")
            }
            set(count) {
                UserDefaults.standard.set(count, forKey: "customCount")
            }
        }
    }

    public func loadJsonFile() {
        if let fileUrl {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                let jsonDecoder = JSONDecoder()
                do {
                    let jsonData = try Data(contentsOf: fileUrl)
                    customApiModel = try jsonDecoder.decode(CustomApiModel.self, from: jsonData)
                    StorageKeys.customAPICount = customApiModel?.count ?? 0
                } catch {
                    print(error)
                }
            } else {
                customApiModel = CustomApiModel(url: "", field: "", currentPrediction: "", count: 0)
            }
        }
    }
    
    public func load(urlSession: URLSessionProtocol = URLSession.shared) async throws {
        guard let customApiModel else { throw ErrorsEnum.errorLoadingObject }
        guard let apiURL = URL(string: customApiModel.url) else {
            throw ErrorsEnum.invalidURL
        }
        do {
            let (urlData, _) = try await urlSession.data(from: apiURL, delegate: nil)
            try await decodeDataFromURLcall(data: urlData)
        } catch {
            throw error
        }
    }
    
    @MainActor
    private func decodeDataFromURLcall(data: Data) async throws {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let customApiModel,
                   let jsonPrediction = jsonObject[customApiModel.field] as? String,
                   let count = jsonObject["count"] as? Int,
                   StorageKeys.customAPICount != count
                {
                    print(jsonPrediction)
                    self.prediction = jsonPrediction
                    self.customApiModel?.currentPrediction = jsonPrediction
                    self.customApiModel?.count = count

                    StorageKeys.customAPICount = count
                }
            } else {
                throw ErrorsEnum.invalidDecodeResponse
            }

        } catch {
            throw ErrorsEnum.invalidDecodeResponse
        }
    }
    
    public func reset() {
        prediction = nil
    }
    
    func removeJsonFile() {
        if let path = fileUrl?.path {
            try? FileManager.default.removeItem(atPath: path)
        }

        UserDefaults.standard.removeObject(forKey: "customCount")
    }

}
