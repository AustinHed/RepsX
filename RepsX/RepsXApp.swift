//
//  RepsXApp.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import SwiftUI
import SwiftData

@main
struct RepsXApp: App {
    
    // Create the container and immediately initialize default exercises.
        let container: ModelContainer = {
            let container = try! ModelContainer(for: Workout.self, Exercise.self, Set.self, PredefinedExercise.self)
            let context = container.mainContext
            // Create an instance of your PredefinedExercisesViewModel and call the initializer function.
            let predefinedVM = PredefinedExercisesViewModel(modelContext: context)
            predefinedVM.initializeDefaultPredefinedExercisesIfNeeded()
            return container
        }()
    
    var body: some Scene {
        WindowGroup {
            LogView()
                .globalKeyboardDoneButton()
//            NavigationStack{
//                AddNewWorkoutView(workout: newWorkout)
//                    .globalKeyboardDoneButton()
//            }
        }
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, PredefinedExercise.self])
    }
}
