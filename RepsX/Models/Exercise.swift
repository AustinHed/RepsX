//
//  Exercise.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import SwiftData
import Foundation
import SwiftUI

/// Represents an exercise at the gym. Note: This is the name + category of an exercise. It is paired with "sets" to build out a "workout"
/// - Parameters:
///   - id: a UUID that is automatically created when initialized
///   - name: The exercise name "ex Bench Press"
///   - category: Which muscle group is targeted ex "chest"
@Model
class Exercise {
    
    //standard variables
    var id: UUID
    var name: String
    var category: String

    //relationship variables
    ///Read as: A single exercise is composed of multiple sets
    ///deleteRule: When you delete the instance of the exercise, you also delete any associated sets
    @Relationship(deleteRule: .cascade) var sets: [Set] = []
    
    ///Read as: An exercise instance belongs to a single workout instance
    @Relationship(deleteRule: .cascade, inverse: \Workout.exercises) var workout: Workout?
    
    //initialize the instance
    init(id: UUID = UUID(), name: String, category: String, workout: Workout) {
        self.id = id //unique ID
        self.name = name //ex bench
        self.category = category //ex chest
        self.workout = workout //ex chest day
    }
    
    //this is a test comment for committs in Exercise
}

