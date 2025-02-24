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
    var setWeight: Double
    
    //relationships
    ///read as: there can be many sets of a given exercise (in a workout)
    ///inverse: \Exercise.sets: This specifies the “inverse” side of the relationship. It tells SwiftData that on the other side of this relationship, in the Exercise model, there is a property called sets that holds the corresponding collection of Set instances.
    ///var exercise: Exercise: This declares a reference to an Exercise instance. A Set must always be associated with an Exercise.
    @Relationship(deleteRule: .cascade, inverse:\Exercise.sets) var exercise: Exercise
    
    
    //init
    init(id: UUID = UUID(),
         exercise: Exercise, //mandatory to assign a set to an exercise
         reps: Int = 0, //defaults to 0 if no value provided
         weight: Double = 0 //defaults to 0 if no value provided
         ) {
        self.id = id
        self.exercise = exercise
        self.reps = reps
        self.setWeight = weight
    }
}
