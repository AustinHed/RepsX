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
        let newExerciseInRoutine = ExerciseInRoutine(exerciseTemplate: exercise, setCount: setCount)
        modelContext.insert(newExerciseInRoutine)
        save()
    }
    
    //delete
    func deleteExerciseInRoutine(_ newExerciseInRoutine: ExerciseInRoutine) {
        modelContext.delete(newExerciseInRoutine)
        save()
    }
    
    //update set count
    func updateSetCount(_ newExerciseInRoutine: ExerciseInRoutine, newSetCount: Int) {
        newExerciseInRoutine.setCount = newSetCount
        save()
    }
    
    //update exercise template
    func updateExerciseTemplate(_ newExerciseInRoutine: ExerciseInRoutine, newExerciseTemplate: ExerciseTemplate) {
        let newExerciseTemplate = newExerciseTemplate
        newExerciseInRoutine.exerciseTemplate = newExerciseTemplate
        save()
    }
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving RoutineExercise: \(error.localizedDescription)")
        }
    }
}
