//
//  InjectObservedObject.swift
//  
//
//  Created by Jonas on 22/11/22.
//

import Foundation
import SwiftUI

final public class InjectObservedObject: ObservableObject {
    
    @Published public private(set) var inject: InjectModel? {
        didSet {
            guard let inject = inject else { return }
            StorageKeys.injectCount = inject.count
        }
    }
    
    public init() { }

    public func load(urlSession: URLSessionProtocol = URLSession.shared) async throws {
        guard let apiURL = URL(string: StorageKeys.injectURL) else {
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
            let decodedResponse = try JSONDecoder().decode(InjectModel.self, from: data)
            if StorageKeys.injectCount != decodedResponse.count {
                DispatchQueue.main.async { [weak self] in
                    self?.inject = decodedResponse
                }
                StorageKeys.injectCount = decodedResponse.count
            }
        } catch {
            throw ErrorsEnum.invalidDecodeResponse
        }
    }
    
    public func reset() {
        inject = nil
    }
    
    public struct StorageKeys {
        static public var injectURL: String {
            get {
                return UserDefaults.standard.string(forKey: "injectURL") ?? ""
            }
            set(apiKey) {
                if apiKey.isEmpty {
                    UserDefaults.standard.set("", forKey: "injectURL")
                } else {
                    UserDefaults.standard.set("https://11z.co/_w/\(apiKey)/selection", forKey: "injectURL")
                }
            }
        }
        static public var injectCount: Int {
            get {
                UserDefaults.standard.integer(forKey: "injectCount")
            }
            set(count) {
                UserDefaults.standard.set(count, forKey: "injectCount")
            }
        }
        
        static public var SectionCaption: String {
            "Enter your Inject ID (Old ID with numbers)"
        }

        static public var FieldCaption: String {
            "API token. e.g., 00000"
        }
        #if DEBUG
        static func removeObjects() {
            UserDefaults.standard.removeObject(forKey: "injectURL")
            UserDefaults.standard.removeObject(forKey: "injectCount")
        }
        #endif
    }
    
#if DEBUG
    func decodeDataFromURLcallDebug(data: Data) throws {
        try decodeDataFromURLcall(data: data)
    }
#endif
}

