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
class RoutineExerciseViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //MARK: Create new
    func addRoutineExercise(routine: Routine, exercise: ExerciseTemplate, setCount: Int = 3) {
        let newRoutineExercise = ExerciseInRoutine(exerciseTemplate: exercise, setCount: setCount)
        modelContext.insert(newRoutineExercise)
        save()
    }
    
    //delete
    func deleteRoutineExercise(_ routineExercise: ExerciseInRoutine) {
        modelContext.delete(routineExercise)
        save()
    }
    //update name
    ///not needed, since it pulls the name directly from the ExerciseTemplate

    //update category
    ///not needed, since it pulls the name directly from the ExerciseTemplate
    
    //update set count
    func updateSetCount(_ routineExercise: ExerciseInRoutine, newSetCount: Int) {
        routineExercise.setCount = newSetCount
        save()
    }
    
    //update exercise template
    func updateExerciseTemplate(_ routineExercise: ExerciseInRoutine, newExerciseTemplate: ExerciseTemplate) {
        routineExercise.exerciseTemplate = newExerciseTemplate
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
