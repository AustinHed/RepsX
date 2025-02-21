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

    func addWorkout(date: Date) {
        let newWorkout = Workout(id: UUID(),name: "Unnamed Workout", startTime: date)
        modelContext.insert(newWorkout)
    }
    
    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
    }

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
