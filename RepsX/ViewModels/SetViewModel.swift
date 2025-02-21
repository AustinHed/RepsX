//
//  SetViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class SetViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addSet(to exercise: Exercise, reps: Int, weight: Double) {
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight)
        exercise.sets.append(newSet)
        modelContext.insert(newSet)
        save()
    }
    
    func deleteSet(_ set: Set, from exercise: Exercise) {
        //1. remove the set from the Exercies's set array
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            exercise.sets.remove(at: index)
        }
        //2. then delete from memory
        modelContext.delete(set)
        save()
        
    }
    
    //update functions
    func updateReps(_ set: Set, newReps: Int) {
        set.reps = newReps
        save()
    }
    
    func updateWeight(_ set: Set, newWeight: Double) {
        set.weight = newWeight
        save()
    }
    
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving set: \(error.localizedDescription)")
        }
    }
    
    //Fetch
    func fetchSets(for exercise: Exercise) -> [Set] {
        return exercise.sets
    }
    
}
