//
//  ElipsedObservedObject.swift
//  
//
//  Created by Jonas on 19/11/22.
//

import Foundation
import SwiftUI

final public class ElipsObservedObject: ObservableObject {
    
    @Published public private(set) var elips: ElipsModel? {
        didSet {
            guard let elips = elips else { return }
            StorageKeys.elipsCount = elips.count
        }
    }
            
    public init() { }
    
    public func load(urlSession: URLSessionProtocol = URLSession.shared) async throws {
        guard let apiURL = URL(string: StorageKeys.elipsURL) else {
            throw ErrorsEnum.invalidURL
        }
        do {
            let (urlData, _) = try await urlSession.data(from: apiURL, delegate: nil)
            try decodeDataFromURLcall(data: urlData)
        } catch {
            throw error
        }
    }
    
    private func decodeDataFromURLcall(data: Data) throws {
        do  {
            let decodedResponse = try JSONDecoder().decode(ElipsModel.self, from: data)
            if StorageKeys.elipsCount != decodedResponse.count {
                DispatchQueue.main.async { [weak self] in
                    self?.elips = decodedResponse
                }
                StorageKeys.elipsCount = decodedResponse.count
            }
            if StorageKeys.elipOutputWords != decodedResponse.outputWords {
                DispatchQueue.main.async { [weak self] in
                    self?.elips = decodedResponse
                }
                StorageKeys.elipOutputWords = decodedResponse.outputWords
            }
        } catch {
            throw ErrorsEnum.invalidDecodeResponse
        }
    }
    
    public func reset() {
        elips = nil
    }
    
    public struct StorageKeys {
        
        static public var elipsURL: String {
            get {
                UserDefaults.standard.string(forKey: "elipsURL") ?? ""
            }
            set(url) {
                UserDefaults.standard.set(url, forKey: "elipsURL")
            }
        }

        static public var elipsCount: Int {
            get {
                UserDefaults.standard.integer(forKey: "elipsCount")
            }
            set(count) {
                UserDefaults.standard.set(count, forKey: "elipsCount")
            }
        }
        
        static public var elipOutputWords: String {
            get {
                UserDefaults.standard.string(forKey: "elipsOutputWords") ?? ""
            }
            set(word) {
                UserDefaults.standard.setValue(word, forKey: "elipsOutputWords")
            }
        }

        static public var SectionCaption: String {
            "Paste you Elips URL that grant access to third party applications"
        }

        static public var FieldCaption: String {
            "e.g., https://pag.gg/{number}/api/{number}"
        }
        
        #if DEBUG
        static func removeObjects() {
            UserDefaults.standard.removeObject(forKey: "elipsURL")
            UserDefaults.standard.removeObject(forKey: "elipsCount")
        }
        #endif
    }
    
    #if DEBUG
    func decodeDataFromURLcallDebug(data: Data) throws {
        try decodeDataFromURLcall(data: data)
    }
    #endif
}
