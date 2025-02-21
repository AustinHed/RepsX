//
//  WorkoutViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import Foundation
import SwiftUI
import SwiftData

/// Manages Workouts and provides the necessary functions
/// - Parameters:
/// -
@Observable class WorkoutViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    //Add and Delete
    func addWorkout(date: Date) {
        let newWorkout = Workout(id: UUID(),name: "Unnamed Workout", startTime: date)
        modelContext.insert(newWorkout)
        save()
    }
    
    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        save()
    }
    
    //Update
    
    func updateName(_ workout: Workout, _ newName: String) {
        workout.name = newName
        save()
    }
    
    func updateStartTime(_ workout: Workout, _ newStartTime: Date) {
        workout.startTime = newStartTime
        save()
    }
    
    func updateEndTime(_ workout: Workout, _ newEndTime: Date?) {
        workout.endTime = newEndTime
        save()
    }
    
    func updateWeight(_ workout: Workout, _ newWeight: Double?) {
        workout.weight = newWeight
        save()
    }
    
    func updateNotes(_ workout: Workout, _ newNotes: String?) {
        workout.notes = newNotes
        save()
    }
    
    func updateRating(_ workout: Workout, _ newRating: Int) {
        workout.rating = newRating
        save()
    }
    
    //Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving workout: \(error.localizedDescription)")
        }
        
    }

    //Fetch
    func fetchWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
}

