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
    
    //MARK: A&D Exercises
    //add an exercise to a workout
    func addExercise(to workout: Workout, name: String, category: Category) {
        let order = workout.exercises.count
        let newExercise = Exercise(id: UUID(), name: name, category: category, workout: workout, order: order)
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
        
        //3. update the order properties
        updateExerciseOrders(for: workout)
        
        save()
    }
    
    
    //MARK: A&D Sets
    //add a Set to an exercise
    func addSet(to exercise: Exercise, reps: Int, weight: Double) {
        let order = exercise.sets.count
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight, order: order)
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
        
        //3. update the setOrder properties
        updateSetOrders(for: exercise)
        
        save()
        
    }
    
    
    //MARK: Update exercises
    //name exercise name
    func updateName(_ exercise: Exercise, newName: String) {
        exercise.name = newName
        save()
    }
    //update exercise category
    func updateCategory(_ exercise: Exercise, newCategory: Category) {
        exercise.category = newCategory
        save()
    }
    //refresh exercise order
    func updateExerciseOrders(for workout: Workout) {
        //first, sort the exercises
        let sortedExercises = workout.exercises.sorted { $0.order < $1.order }
        //then, update the order properties
        for (index, exercise) in sortedExercises.enumerated() {
            exercise.order = index
        }
        //then save
        save()
    }
    
    
    //MARK: Update sets
    //update set reps
    func updateReps(_ set: Set, newReps: Int) {
        set.reps = newReps
        save()
    }
    //update set weight
    func updateWeight(_ set: Set, newWeight: Double) {
        set.setWeight = newWeight
        save()
    }
    //refresh set order
    func updateSetOrders(for exercise: Exercise) {
        //first, sort the sets
        let sortedSets = exercise.sets.sorted { $0.order < $1.order }
        //then update the setOrder properties
        for (index, set) in sortedSets.enumerated() {
            set.order = index
        }
        //then save
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
