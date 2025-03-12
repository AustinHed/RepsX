//
//  LookbackOption.swift
//  RepsX
//
//  Created by Austin Hed on 3/12/25.
//

// Define the available lookback options.
enum LookbackOption: Int, CaseIterable, Identifiable {
    case seven = 7, thirty = 30, ninty = 90, all = 0
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
        case .seven: return "Week"
        case .thirty: return "Month"
        case .ninty: return "Quarter"
        case .all: return "All Time"
        }
    }
}
