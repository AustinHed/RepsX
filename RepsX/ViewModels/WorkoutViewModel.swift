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
@Observable
class WorkoutViewModel {
    private var modelContext: ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    
    //MARK: A&D Workouts
    //add a new Workout to memory
    func addWorkout(date: Date) -> Workout {
        let newWorkout = Workout(id: UUID(),name: "", startTime: date)
        modelContext.insert(newWorkout)
        save()
        return newWorkout
    }
    //delete a workout from Memory
    func deleteWorkout(_ workout: Workout) {
        //first, iterate over the exercises
        for exercise in workout.exercises {
            deleteExercise(exercise, from: workout)
        }
        //then, delete the workout
        modelContext.delete(workout)
        //then, save
        save()
    }
    
    
    //MARK: A&D Exercises
    //add an exercise to a specific Workout
    func addExercise(to workout: Workout) {
        let order = workout.exercises.count
        let newExercise = Exercise(id: UUID(), name: "Unnamed Exercise", category: .chest, workout: workout, order: order)
        workout.exercises.append(newExercise)
        modelContext.insert(newExercise)
        save()
    }
    //delete exercise
    func deleteExercise(_ exercise: Exercise, from workout: Workout) {
        //1. Remove the exercise from the workout's exercises array. This is to avoid potential UI issues where a view depends on the array
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)  // Remove the exercise from the workout
        }
        
        // 2. Now safely delete the exercise from the context
        modelContext.delete(exercise)
        
        //3. refresh exercise order property
        updateExerciseOrders(for: workout)
        save()
    }
    
    
    //MARK: Update Workout functions
    //name
    func updateName(_ workout: Workout, _ newName: String) {
        workout.name = newName
        save()
    }
    //start time
    func updateStartTime(_ workout: Workout, _ newStartTime: Date) {
        workout.startTime = newStartTime
        save()
    }
    //end time
    func updateEndTime(_ workout: Workout, _ newEndTime: Date?) {
        workout.endTime = newEndTime
        save()
    }
    //bodyweight
    func updateWeight(_ workout: Workout, _ newWeight: Double?) {
        workout.weight = newWeight
        save()
    }
    //notes
    func updateNotes(_ workout: Workout, _ newNotes: String?) {
        workout.notes = newNotes
        save()
    }
    //rating
    func updateRating(_ workout: Workout, _ newRating: Int) {
        if newRating == 0 {
            workout.rating = nil
        } else {
            workout.rating = newRating
        }
        save()
    }
    
    
    //MARK: Update Exercise
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
    
    
    //MARK: Save & Fetch
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving workout: \(error.localizedDescription)")
        }
        
    }
    //fetch
    func fetchWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    
    //MARK: Date & Time helpers
    //Workout Details format - Returns a formatted date string like "Fri, Feb 21 @ 9:03AM"
    func formattedDate(_ date: Date) -> String {
        let workoutDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "EEE, MMM d ' @ 'h:mma"
            return formatter
        }()
        return workoutDateFormatter.string(from: date)
    }
    
    //toolbar format
    func toolbarDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        let formattedDate = formatter.string(from: date)
        return formattedDate
    }
}

