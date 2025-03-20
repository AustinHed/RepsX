//
//  StringExtension.swift
//  RepsX
//
//  Created by Austin Hed on 3/19/25.
//
import Foundation
import SwiftUI

extension String {
    func capitalizingFirstLetter() -> String {
        guard let firstLetter = first else { return self }
        return firstLetter.uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
