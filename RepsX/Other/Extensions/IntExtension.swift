//
//  IntExtension.swift
//  RepsX
//
//  Created by Austin Hed on 3/5/25.
//

extension Int {
    var ordinal: String {
        var suffix = "th"
        let ones = self % 10
        let tens = (self / 10) % 10
        if tens != 1 {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: break
            }
        }
        return "\(self)\(suffix)"
    }
}
