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
    // This ensures that if the category is deleted, the reference will be set to nil.
    @Relationship(deleteRule: .nullify)
    var category: CategoryModel?
    
    var order: Int
    var intensity: Int?
    var modality: ExerciseModality
    var templateId: UUID
    
    //when an Exercise is initialized, it always starts with no associated sets
    var sets: [Set] = []
    
    ///Read as: An exercise instance belongs to a single workout instance. This is mandatory
    @Relationship(deleteRule: .cascade, inverse: \Workout.exercises) var workout: Workout?
    var workoutStartTime: Date
    
    
    //initialize the instance
    init(id: UUID = UUID(),
         name: String,
         category: CategoryModel? = nil,
         workout: Workout,
         order: Int = 0,
         intensity: Int? = nil,
         modality: ExerciseModality = .repetition, //TODO: not all exercises are reps - should be allowed others
         templateId: UUID,
         workoutStartTime: Date
        ) {
        self.id = id //unique ID
        self.name = name //ex bench
        self.category = category //ex chest
        self.workout = workout //ex chest day
        self.order = order
        self.intensity = intensity //nil, 1-3
        self.modality = modality
        self.templateId = templateId
        self.workoutStartTime = workoutStartTime
    }
}

