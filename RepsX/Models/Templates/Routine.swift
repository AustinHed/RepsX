//
//  Routine.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//
import SwiftData
import Foundation
import SwiftUI
/*
 - name
 - list of exercises
 
 */

@Model
class Routine: Identifiable {
    var id: UUID
    var name: String
    var colorHex: String?
    var exercises: [ExerciseInRoutine]
    var favorite: Bool
    
    init(id: UUID = UUID(),
         name: String = "Unknown Exercise",
         colorHex: String? = nil,
         exercises: [ExerciseInRoutine] = [],
         favorite: Bool = false
        ){
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.exercises = exercises
        self.favorite = favorite
    }
    
    //computed color property that turns a hex into a color for usage
    var color: Color {
        if let hex = colorHex, let uiColor = UIColor(hex: hex) {
            return Color(uiColor)
        } else {
            return Color.gray
        }
    }
}

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 1.0
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
