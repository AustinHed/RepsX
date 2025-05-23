//
//  RoutineViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//
import SwiftUI
import SwiftData
import Foundation

@Observable
class RoutineViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //MARK: Create new Routine
    func addRoutine(name:String) -> Routine {
        let newRoutine = Routine(name: name)
        modelContext.insert(newRoutine)
        save()
        return newRoutine
    }

    
    //MARK: Delete
    func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        save()
    }
    
    //MARK: Update
    func updateRoutine(_ routine: Routine, newName: String? = nil, newGroup: RoutineGroup? = nil) {
        if let newName = newName {
            routine.name = newName
        }
        if let newGroup = newGroup {
            routine.group = newGroup
        }
        save()

    }
    //favorite
    func favoriteRoutine(_ routine: Routine) {
        routine.favorite.toggle()
        save()
    }
    
    //Add new ExerciseInRoutines
    func addExerciseInRoutine(to routine: Routine, exercise: ExerciseTemplate, setCount: Int = 3) {
        let newExerciseInRoutine = ExerciseInRoutine(id: UUID(), exerciseTemplate: exercise, setCount: setCount)
        routine.exercises.append(newExerciseInRoutine)
        modelContext.insert(newExerciseInRoutine)
        save()
    }
    
    //deleteExerciseTemplates
    func deleteExerciseInRoutine(_ exerciseInRoutine: ExerciseInRoutine) {
        modelContext.delete(exerciseInRoutine)
        save()
    }
    
    //MARK: Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving Routines: \(error.localizedDescription)")
        }
    }

}
