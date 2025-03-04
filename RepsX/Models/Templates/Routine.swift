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
        if colorHex != nil {
            let color = Color(hexString: colorHex!)
            return Color(color)
        } else {
            return Color.gray
        }
    }
}
