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

    func addExercise(to workout: Workout, name: String, category: Category) {
        let newExercise = Exercise(id: UUID(), name: name, category: category, workout: workout)
        workout.exercises.append(newExercise)
        modelContext.insert(newExercise)
        save()
    }

    func deleteExercise(_ exercise: Exercise, from workout: Workout) {
        //1. Remove the exercise from the workout's exercises array. This is to avoid potential UI issues where a view depends on the array
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)  // Remove the exercise from the workout
        }

        // 2. Now safely delete the exercise from the context
        modelContext.delete(exercise)
        save()
    }
    
    //update functions
    func updateName(_ exercise: Exercise, newName: String) {
        exercise.name = newName
        save()
    }
    
    func updateCategory(_ exercise: Exercise, newCategory: Category) {
        exercise.category = newCategory
        save()
    }
    
    //Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving exercise: \(error.localizedDescription)")
        }
    }
        
    
    //Fetch function
    func fetchExercises(for workout: Workout) -> [Exercise] {
            return workout.exercises
    }
}
