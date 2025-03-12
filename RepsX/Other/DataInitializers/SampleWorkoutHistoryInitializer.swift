//
//  SampleWorkoutHistoryInitializer.swift
//  RepsX
//
//  Created by Austin Hed on 3/5/25.
//

import SwiftData
import Foundation

func initializeWorkoutsIfNeeded(context: ModelContext) {
    do {
        // 1. Check if there are any existing workouts.
        let workoutDescriptor = FetchDescriptor<Workout>()
        let existingWorkouts = try context.fetch(workoutDescriptor)
        
        // Only proceed if no workouts exist.
        guard existingWorkouts.isEmpty else { return }
        
        // 2. Fetch all exercise templates so we can attach them to new workouts.
        let templateDescriptor = FetchDescriptor<ExerciseTemplate>()
        let allTemplates = try context.fetch(templateDescriptor)
        
        // 3. Create 21 workouts, one for each day in the last 3 weeks.
        let calendar = Calendar.current
        
        for dayOffset in 0..<21 {
            // Calculate the date for this offset (0 = today, 1 = yesterday, etc.)
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            
            // Pick a random start time for the workout (e.g., between 6 AM and 8 AM).
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
            dateComponents.hour = Int.random(in: 6...8)
            dateComponents.minute = [0, 15, 30, 45].randomElement()!
            
            // Construct the final startTime.
            let startTime = calendar.date(from: dateComponents) ?? dayDate
            
            // Random workout length between 45 and 65 minutes (in seconds).
            let workoutLengthSeconds = Double.random(in: (45 * 60)...(65 * 60))
            let endTime = startTime.addingTimeInterval(workoutLengthSeconds)
            
            // Create a new Workout object.
            let newWorkout = Workout(startTime: startTime, endTime: endTime)
            
            // 4. Randomly select 2–5 exercise templates for this workout.
            let exerciseCount = Int.random(in: 2...5)
            let selectedTemplates = allTemplates.shuffled().prefix(exerciseCount)
            
            for template in selectedTemplates {
                // Create an Exercise referencing the template.
                let exercise = Exercise(name: template.name,
                                        category: template.category,
                                        workout: newWorkout,
                                        modality: template.modality,
                                        templateId: template.id
                )
                
                // 5. For each exercise, create 2–4 sets with random weights, reps, and intensity.
                let setCount = Int.random(in: 2...4)
                for _ in 0..<setCount {
                    let reps = Int.random(in: 8...12)
                    let weight = Double.random(in: 50...150)
                    let exerciseSet = Set(exercise: exercise, reps: reps, weight: weight)
                    // Set an intensity value between 0 and 5.
                    exerciseSet.intensity = Int.random(in: 0...5)
                    
                    exercise.sets.append(exerciseSet)
                }
                
                // Attach this exercise to the workout.
                newWorkout.exercises.append(exercise)
            }
            
            // Insert the newly created workout into the context.
            context.insert(newWorkout)
        }
        
        // 6. Save all changes in one transaction.
        try context.save()
        
    } catch {
        print("Error initializing workouts: \(error.localizedDescription)")
    }
}
