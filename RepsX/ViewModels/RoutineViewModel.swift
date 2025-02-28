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
    
    //MARK: Add
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
    
    //MARK: Update Name
    func updateRoutineName(_ routine: Routine, newName: String) {
        routine.name = newName
        save()
    }
    
    //addExerciseTemplates
    
    //deleteExerciseTemplates
    
    //MARK: Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving Routines: \(error.localizedDescription)")
        }
    }

}
