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
    
    
    //MARK: Add & Delete
    //add set
    func addSet(to exercise: Exercise, reps: Int, weight: Double) {
        //TODO: this should differ based on exercise.modality
        let order = exercise.sets.count
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight, order: order)
        exercise.sets.append(newSet)
        modelContext.insert(newSet)
        save()
    }
    //delete set
    func deleteSet(_ set: Set, from exercise: Exercise) {
        //1. remove the set from the Exercies's set array
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            exercise.sets.remove(at: index)
        }
        //2. then delete from memory
        modelContext.delete(set)
        
        //3. update the setOrder properties
        updateSetOrders(for: exercise)
        
        save()
        
    }
    
    
    //MARK: Update
    //global update
    func updateSet(_ set: Set, newReps: Int?, newWeight: Double?, newIntensity: Int?) {
        //reps
        if let newReps = newReps {
            set.reps = newReps
        }
        
        //weight
        if let newWeight = newWeight {
            set.setWeight = newWeight
        }
        
        //intensity
        if let newIntensity = newIntensity {
            set.intensity = newIntensity
        }
        
        //placeholder - update time
        
        save()
    }
    
    //reps
    func updateReps(_ set: Set, newReps: Int) {
        set.reps = newReps
        save()
    }
    //weight
    func updateWeight(_ set: Set, newWeight: Double) {
        set.setWeight = newWeight
        save()
    }
    //intensity
    func updateIntensity(_ set: Set, newIntensity:Int) {
        set.intensity = newIntensity
        save()
    }
    
    //refresh order
    func updateSetOrders(for exercise: Exercise) {
        //first, sort the sets
        let sortedSets = exercise.sets.sorted { $0.order < $1.order }
        //then update the order properties
        for (index, set) in sortedSets.enumerated() {
            set.order = index
        }
        //then save
        save()
    }
    
    
    //MARK: Other
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
