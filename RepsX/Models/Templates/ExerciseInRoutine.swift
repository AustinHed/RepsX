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
    var setCount: Int
    
    init(id: UUID = UUID(), exerciseTemplate: ExerciseTemplate?, setCount: Int) {
        self.id = id
        self.exerciseTemplate = exerciseTemplate
    
        
        //can update the exerciseTemplate to fix these properties
        
        // Capture key properties from the template.
        self.exerciseName = exerciseTemplate?.name ?? "Unnamed Exercise" //if the exerciseTemplate is deleted, then this becomes "unnamed"
        // Capture key properties from the template.
        self.exerciseCategory = exerciseTemplate?.category ?? CategoryModel(name: "Uncategorized")
        self.setCount = setCount
    }
}
