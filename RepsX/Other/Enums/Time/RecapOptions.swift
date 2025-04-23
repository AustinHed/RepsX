//
//  RecapOptions.swift
//  RepsX
//
//  Created by Austin Hed on 4/22/25.
//

import Foundation

enum RecapOptions: Int, CaseIterable, Codable {
    case Seven = 7
    case Thirty = 30
    case Ninty = 90
    
    init() {
        self = .Thirty
    }
}
