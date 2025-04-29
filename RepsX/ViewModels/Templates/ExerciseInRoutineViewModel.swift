//
//  RoutineExerciseViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import Foundation

@Observable
class ExerciseInRoutineViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //MARK: Create new
    func addExerciseInRoutine(routine: Routine, exercise: ExerciseTemplate, setCount: Int = 3) {
        let order = routine.exercises.count
        let newExerciseInRoutine = ExerciseInRoutine(order: order, exerciseTemplate: exercise, setCount: setCount)
        modelContext.insert(newExerciseInRoutine)
        save()
    }
    
    //delete
    func deleteExerciseInRoutine(_ newExerciseInRoutine: ExerciseInRoutine) {
        modelContext.delete(newExerciseInRoutine)
        save()
    }
    
    //MARK: Update
    func updateExerciseInRoutine(_ exerciseInRoutine: ExerciseInRoutine, newSetCount: Int? = nil, newExerciseTemplate: ExerciseTemplate? = nil, newOrder: Int? = nil) {
        if let newSetCount = newSetCount {
            exerciseInRoutine.setCount = newSetCount
        }
        
        //replace the exercise template
        if let newExerciseTemplate = newExerciseTemplate {
            exerciseInRoutine.exerciseTemplate = newExerciseTemplate
        }
        //reorder
        if let newOrder = newOrder {
            exerciseInRoutine.order = newOrder
        }
        
        save()
    }
    
    //MARK: Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving RoutineExercise: \(error.localizedDescription)")
        }
    }
}
