//
//  ExerciseViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//


import Foundation
import SwiftData
import SwiftUI

@Observable class ExerciseViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addExercise(to workout: Workout, name: String, category: String) {
        let newExercise = Exercise(id: UUID(), name: name, category: category, workout: workout)
        workout.exercises.append(newExercise)
        modelContext.insert(newExercise)
    }

    func deleteExercise(_ exercise: Exercise, from workout: Workout) {
        // 1. Manually nullify the inverse relationship in Exercise
        exercise.workout = nil  // Nullify the workout relationship on the exercise

        // 2. Remove the exercise from the workout's exercises array
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)  // Remove the exercise from the workout
        }

        // 3. Now safely delete the exercise from the context
        modelContext.delete(exercise)
    }

    func fetchExercises(for workout: Workout) -> [Exercise] {
            return workout.exercises
        }
}
