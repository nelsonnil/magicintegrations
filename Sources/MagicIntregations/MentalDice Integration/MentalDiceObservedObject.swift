//
//  MentalDiceObservedObject.swift
//
//
//  Created by Jonás Socas on 21/11/2022.
//
//

import Foundation
import SwiftUI

final public class MentalDiceObservedObject: ObservableObject {
    static public let shared: MentalDiceObservedObject = MentalDiceObservedObject()
    @Published public var connected = false
    @Published public private(set) var dice = MentalDice.shared.dice
    @Published public private(set) var detectedColor: Die.Color? {
        didSet {
            if detectedColor != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.detectedColor = nil
                }
            }
        }
    }

    private init() {
        let mentalDice = MentalDice.shared
        mentalDice.delegate = self
    }

    public func connect() {
        MentalDice.shared.connect()
    }

    public func disconnect() {
        MentalDice.shared.disconnect()
    }
}

extension MentalDiceObservedObject: MentalDiceDelegate {
    public func didConnect() {
        connected = true
    }

    public func didDisconnect() {
        connected = false
    }

    public func didUpdate(dice: [Die]) {
        self.dice = dice
    }

    public func didDetect(color: Die.Color) {
        detectedColor = color
    }
}
