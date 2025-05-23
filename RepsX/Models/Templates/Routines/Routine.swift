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
    var exercises: [ExerciseInRoutine]
    var favorite: Bool
    var group: RoutineGroup? //a single grouping the Routine belongs to, optional

    init(id: UUID = UUID(),
         name: String = "Unknown Routine",
         exercises: [ExerciseInRoutine] = [],
         favorite: Bool = false,
         group: RoutineGroup? = nil) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.favorite = favorite
        self.group = group
    }
}
