//
//  SampleData.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import Foundation
import SwiftData


@MainActor
class SampleWorkout {
    
    static let shared = SampleWorkout()
    let modelContainer: ModelContainer
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([
            Workout.self,
            Exercise.self,
            Set.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            //need to edit this function
            insertSampleData()
            
            try context.save()
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    let sampleExercises: [(name: String, category: CategoryModel)] = [
        ("Bench Press", CategoryModel(name: "test")),
        ("Squat", CategoryModel(name: "test")),
        ("Deadlift", CategoryModel(name: "test")),
        ("Overhead Press", CategoryModel(name: "test"))
    ]
    
    let sampleSets: [(reps: Int, weight: Double)] = [
        (10, 100),
        (8, 105),
        (6, 110),
        (10, 100),
        (8, 105)
    ]
    
    private func insertSampleData() {
        // For each workout in your sample data...
        for workout in Workout.sampleWorkout {
            // ...create one exercise per each sample exercise (4 total)
            for exerciseData in sampleExercises {
                let exercise = Exercise(name: exerciseData.name, category: exerciseData.category, workout: workout)
                
                // For each exercise, add 12 sets using sampleSets data
                for setData in sampleSets {
                    let set = Set(id: UUID(), exercise: exercise, reps: setData.reps, weight: setData.weight)
                    exercise.sets.append(set)
                    context.insert(set)
                }
                
                workout.exercises.append(exercise)
                context.insert(exercise)
            }
            context.insert(workout)
        }
    }
}
