//
//  Extensions.swift
//  
//
//  Created by Jonás - HORICAN on 31/12/23.
//

import Foundation

extension FileManager {
    public var documentsDirectory: URL {
        self.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
