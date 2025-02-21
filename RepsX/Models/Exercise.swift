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
    var category: Category?
    
    //when an Exercise is initialized, it always starts with no associated sets
    var sets: [Set] = []
    
    ///Read as: An exercise instance belongs to a single workout instance. This is mandatory
    @Relationship(deleteRule: .cascade, inverse: \Workout.exercises) var workout: Workout
    
    //initialize the instance
    init(id: UUID = UUID(),
         name: String,
         category: Category?,
         workout: Workout) {
        self.id = id //unique ID
        self.name = name //ex bench
        self.category = category //ex chest
        self.workout = workout //ex chest day
    }
}
