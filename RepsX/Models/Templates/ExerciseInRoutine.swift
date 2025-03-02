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
    //standard UUID
    var id: UUID
    
    // The relationship to the ExerciseTemplate
    var exerciseTemplate: ExerciseTemplate?
    
    // Denormalized properties to preserve data even if the template is deleted.
    var exerciseName: String
    var exerciseCategory: CategoryModel?
    var exerciseModality: ExerciseModality
    var setCount: Int
    
    // relationship to the routine it belongs in
    @Relationship(deleteRule: .cascade, inverse: \Routine.exercises) var routine: Routine?
    
    init(id: UUID = UUID(),
         exerciseTemplate: ExerciseTemplate?,
         setCount: Int
    ) {
        self.id = id
        self.exerciseTemplate = exerciseTemplate
        // Capture key properties from the template. Should change based on the linked ExerciseTemplate
        /// when there is an available/linked exerciseTemplate, inherit the values
        /// when there is no parent template, then default to "unknown" values
        self.exerciseName = exerciseTemplate?.name ?? "Unnamed Exercise" //if the exerciseTemplate is deleted, then this becomes "unnamed"
        self.exerciseCategory = exerciseTemplate?.category ?? CategoryModel(name: "Uncategorized")
        self.exerciseModality = exerciseTemplate?.modality ?? .other
        self.setCount = setCount
    }
}
