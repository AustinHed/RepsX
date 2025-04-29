//
//  ExerciseViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//


import Foundation
import SwiftData
import SwiftUI

//MARK: Core functions
@Observable
class ExerciseViewModel {
    
    private var modelContext: ModelContext
    
    //init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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

//MARK: Exercise Functions
extension ExerciseViewModel {
    //MARK: Add and Delete
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

    
    //MARK: Update
    //global update function for clenliness
    func updateExercise(_ exercise: Exercise, newName: String? = nil, newCategory: CategoryModel? = nil, newIntensity: Int? = nil, newModality: ExerciseModality? = nil) {
        if let newName = newName {
            exercise.name = newName
        }
        if let newCategory = newCategory {
            exercise.category = newCategory
        }
        if let newIntensity = newIntensity {
            exercise.intensity = newIntensity
        }
        if let newModality = newModality {
            exercise.modality = newModality
        }
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
}

//MARK: Set Functions
extension ExerciseViewModel {
    //MARK: Add and Delete
    //add a Set to an exercise
    func addSet(to exercise: Exercise, reps: Int, weight: Double, time: Double, distance: Double) {
        let order = exercise.sets.count
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight, time: time, distance: distance, order: order)
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
    
    //MARK: Update
    //global update sets function
    func updateSet(_ set: Set, newReps: Int? = nil, newWeight: Double? = nil, newTime: Double? = nil, newDistance: Double? = nil, newIntensity:Int? = nil) {
        if let newReps = newReps {
            set.reps = newReps
        }
        if let newWeight = newWeight {
            set.weight = newWeight
        }
        
        if let newTime = newTime {
            set.time = newTime
        }
        
        if let newDistance = newDistance {
            set.distance = newDistance
        }
        if let newIntensity = newIntensity {
            set.intensity = newIntensity
        }
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
}

//MARK: Prev Set Values
extension ExerciseViewModel {
    
    func fetchMostRecentWorkout(for templateId: UUID) -> [Set] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { exercise in
                exercise.templateId == templateId
            },
            sortBy: [SortDescriptor(\.workoutStartTime, order: .reverse)]
        )

        do {
            //print("fetch function for: \(templateId)")
            let all = try modelContext.fetch(descriptor)
            if all.count > 0 {
                print("returned more than 1")
                print(all.second?.sets.count ?? "no sets")
                return all.second?.sets ?? []
            } else {
                print("returned none")
                return []
            }
        } catch {
            print("Error fetching recent sets: \(error)")
            return []
        }
    }
}


