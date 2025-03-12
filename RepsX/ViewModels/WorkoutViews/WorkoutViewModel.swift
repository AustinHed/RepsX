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
    
    

}

//MARK: Workouts
extension WorkoutViewModel {
    
    //add a new Workout to memory
    func addWorkout(date: Date) -> Workout {
        let newWorkout = Workout(id: UUID(),name: "", startTime: date)
        modelContext.insert(newWorkout)
        save()
        return newWorkout
    }
    
    //add a new workout using a Routine
    func addWorkoutFromRoutine(_ routine: Routine, date: Date) -> Workout {
        //first, create the Workout
        let newWorkout = Workout(id: UUID(),name: routine.name, startTime: date, color: routine.colorHex)
        modelContext.insert(newWorkout)
        
        //then, create the Exercises in the workout
        for exerciseInRoutine in routine.exercises {
            //create the individual Exercise
            let newExercise = addPremadeExercise(to: newWorkout, exercise: exerciseInRoutine.exerciseTemplate!)
            let setCount = exerciseInRoutine.setCount
            //need to also create the sets
            for _ in 0..<setCount {
                addSet(to: newExercise, reps: 0, weight: 0, time: 0, distance: 0)
            }
        }
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
    
    //MARK: Update Workout functions
    //global update
    func updateWorkout(_ workout: Workout, newName: String? = nil, newStartTime: Date? = nil, newEndTime:Date? = nil, newNotes: String? = nil, newRating: Int? = nil, newColor: String? = nil) {
        //update name
        if let newName = newName {
            workout.name = newName
        }
        
        //update start time
        if let newStartTime = newStartTime {
            workout.startTime = newStartTime
        }
        //update end time
        if let newEndTime = newEndTime {
            workout.endTime = newEndTime
        }
        //update notes
        if let newNotes = newNotes {
            workout.notes = newNotes
        }
        //update rating
        if let newRating = newRating {
            workout.rating = max(1, min(5, newRating))
        }
        
        if let newColor = newColor{
            workout.color = newColor
        }
        //save
        save()
    }
    
}

//MARK: Exercises
extension WorkoutViewModel {
    //add an exercise to a specific Workout, using an ExerciseTemplate
    func addPremadeExercise(to workout: Workout, exercise: ExerciseTemplate) -> Exercise {
        let order = workout.exercises.count
        let newExercise = Exercise(id: UUID(),
                                   name: exercise.name,
                                   category: exercise.category,
                                   workout: workout,
                                   order: order,
                                   modality: exercise.modality,
                                   templateId: exercise.id
        )
        workout.exercises.append(newExercise)
        modelContext.insert(newExercise)
        save()
        return newExercise
    }
    
    func replaceExercise(in workout: Workout, exerciseToRemove: Exercise, exerciseToAdd: ExerciseTemplate) {
        //find the index of the exercise to remove
        if let index = workout.exercises.firstIndex(where: {$0.id == exerciseToRemove.id}) {
            //get that index
            let exerciseOrder = exerciseToRemove.order
            //create a new exercise using the exercise template
            let newExercise = Exercise(name: exerciseToAdd.name, category: exerciseToAdd.category, workout: workout, templateId: exerciseToAdd.id)
            newExercise.order = exerciseOrder
            //swap that exercise into the array
            workout.exercises[index] = newExercise
            //count how many sets need to be added
            let setCount = exerciseToRemove.sets.count
            for _ in 0..<setCount {
                addSet(to: newExercise, reps: 0, weight: 0, time: 0, distance: 0)
            }
            //delete the removed exercise
            deleteExercise(exerciseToRemove, from: workout)
            save()
        }
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
    
    //ensure exercises are in the right order
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

//MARK: Sets
extension WorkoutViewModel {
    func addSet(to exercise: Exercise, reps: Int, weight: Double, time: Double, distance: Double) {
        let order = exercise.sets.count
        let newSet = Set(id: UUID(), exercise: exercise, reps: reps, weight: weight, time: time, distance: distance, order: order)
        exercise.sets.append(newSet)
        modelContext.insert(newSet)
        save()
    }
}

//MARK: Date & Time Helpers
extension WorkoutViewModel {
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

