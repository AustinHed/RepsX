//
//  RoutineExercise.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import Foundation

@Model
class ExerciseInRoutine: Identifiable {
    // Standard UUID.
    var id: UUID
    
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
        exerciseTemplate?.modality ?? .other
    }
    
    // Relationship to the routine it belongs in.
    @Relationship(deleteRule: .cascade, inverse: \Routine.exercises)
    var routine: Routine?
    
    init(id: UUID = UUID(),
         exerciseTemplate: ExerciseTemplate?,
         setCount: Int
    ) {
        self.id = id
        self.exerciseTemplate = exerciseTemplate
        self.setCount = setCount
    }
}
