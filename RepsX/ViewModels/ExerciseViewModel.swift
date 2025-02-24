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
    
    //MARK: Add and delete
    //add an exercise to a workout
    func addExercise(to workout: Workout, name: String, category: Category) {
        let newExercise = Exercise(id: UUID(), name: name, category: category, workout: workout)
        workout.exercises.append(newExercise)
        modelContext.insert(newExercise)
        save()
    }
    
    //delete an exercise from a workout
    func deleteExercise(_ exercise: Exercise, from workout: Workout) {
        //1. Remove the exercise from the workout's exercises array. This is to avoid potential UI issues where a view depends on the array
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)  // Remove the exercise from the workout
        }
        
        // 2. Now safely delete the exercise from the context
        modelContext.delete(exercise)
        save()
    }
    
    
    //add a Set to an exercise
    func addSet(to exercise: Exercise, reps: Int, weight: Double) {
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight)
        exercise.sets.append(newSet)
        modelContext.insert(newSet)
        save()
    }
    
    //delete a Set from an exercise
    func deleteSet(_ set: Set, from exercise: Exercise) {
        //1. remove the set from the Exercies's set array
        if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
            exercise.sets.remove(at: index)
        }
        //2. then delete from memory
        modelContext.delete(set)
        save()
        
    }
    
    //MARK: Update functions
    //name
    func updateName(_ exercise: Exercise, newName: String) {
        exercise.name = newName
        save()
    }
    
    //category
    func updateCategory(_ exercise: Exercise, newCategory: Category) {
        exercise.category = newCategory
        save()
    }
    
    //update sets
    //update functions
    func updateReps(_ set: Set, newReps: Int) {
        set.reps = newReps
        save()
    }
    
    func updateWeight(_ set: Set, newWeight: Double) {
        set.setWeight = newWeight
        save()
    }
    
    //MARK: Save and Fetch
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
