//
//  RoutineExercise.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import Foundation

//this is an instance of an Exercise template stored in a routine

@Model
class ExerciseInRoutine: Identifiable {
    // Standard UUID.
    var id: UUID
    
    var order: Int
    
    // The relationship to the ExerciseTemplate.
    var exerciseTemplate: ExerciseTemplate?
    
    // The number of sets.
    var setCount: Int
    
    // Computed properties that update automatically when exerciseTemplate changes.
    var exerciseName: String {
        exerciseTemplate?.name ?? "Unnamed Exercise"
    }
    
    var exerciseCategory: CategoryModel? {
        exerciseTemplate?.category ?? CategoryModel(name: "Uncategorized")
    }
    
    var exerciseModality: ExerciseModality {
        exerciseTemplate?.modality ?? .repetition
    }
    
    // Relationship to the routine it belongs in.
    @Relationship(inverse: \Routine.exercises)
    var routine: Routine?
    
    init(id: UUID = UUID(),
         order: Int = 0,
         exerciseTemplate: ExerciseTemplate?,
         setCount: Int
    ) {
        self.order = order
        self.id = id
        self.exerciseTemplate = exerciseTemplate
        self.setCount = setCount
    }
}
