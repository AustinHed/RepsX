//
//  Set.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//
import SwiftData
import Foundation
import SwiftUI

/// Represents a single set of an exercise in a workout
/// - Parameters:
/// - id:a unique ID for the set
/// - reps: the number of repetitions performed of a given exercise
/// - weight: the weight used for each rep
@Model
class Set {
    //the basic params of a set
    var id: UUID
    var reps: Int
    var weight: Double
    
    //relationships
    ///TODO: Add relationship set <> exercise, many <> one
    ///read as: there can be many sets of a given exercise (in a workout)
    @Relationship(inverse:\Exercise.sets) var exercise: Exercise?
    
    
    //init
    init(id: UUID = UUID(), reps: Int, weight: Double, exercise: Exercise) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.exercise = exercise
    }
}
