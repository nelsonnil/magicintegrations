//
//  WikiTestObservedObject.swift
//  
//
//  Created by Jonas on 22/11/22.
//

import Foundation
import SwiftUI

final public class WikiTestObservedObject: ObservableObject {
    
    @Published public private(set) var wikitest: WikiTestModel? {
        didSet {
            guard let wikitest = wikitest else { return }
            StorageKeys.wikitestCount = wikitest.modified
        }
    }
        
    public init() { }
    
    public func load(urlSession: URLSessionProtocol = URLSession.shared) async throws {
        guard let apiURL = URL(string: StorageKeys.wikitestURL) else {
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
            let decodedResponse = try JSONDecoder().decode(WikiTestModel.self, from: data)
            if StorageKeys.wikitestCount != decodedResponse.modified {
                DispatchQueue.main.async { [weak self] in
                    self?.wikitest = decodedResponse
                }
                StorageKeys.wikitestCount = decodedResponse.modified
            }
        } catch {
            throw ErrorsEnum.invalidDecodeResponse
        }
    }
    
    public func reset() {
        wikitest = nil
    }
    
    public struct StorageKeys {
        static public var wikitestURL: String {
            get {
                guard let url = UserDefaults.standard.string(forKey: "wikitestURL"), url != "" else {
                    return ""
                }
                return "\(url)/json"
            }
            set(url) {
                UserDefaults.standard.set(url, forKey: "wikitestURL")
            }
        }
        static public var wikitestCount: Int {
            get {
                UserDefaults.standard.integer(forKey: "wikitestCount")
            }
            set(count) {
                UserDefaults.standard.set(count, forKey: "wikitestCount")
            }
        }
        
        static public var SectionCaption: String {
            "Paste you Elips URL that grant access to third party applications"
        }

        static public var FieldCaption: String {
            "e.g., https://tinyhost.pw/w/{number}/xlcZsSe24s"
        }
        #if DEBUG
        static func removeObjects() {
            UserDefaults.standard.removeObject(forKey: "wikietestURL")
            UserDefaults.standard.removeObject(forKey: "wikitestCount")
        }
        #endif
    }
    
    #if DEBUG
    func decodeDataFromURLcallDebug(data: Data) throws {
        try decodeDataFromURLcall(data: data)
    }
    #endif
}
