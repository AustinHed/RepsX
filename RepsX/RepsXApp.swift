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
    
    //testing add workout view
    //let newWorkout = Workout(id: UUID(), startTime: Date())
    
    var body: some Scene {
        WindowGroup {
            LogView()
                .globalKeyboardDoneButton()
//            NavigationStack{
//                AddNewWorkoutView(workout: newWorkout)
//                    .globalKeyboardDoneButton()
//            }
        }
        .modelContainer(for: [Workout.self, Exercise.self, Set.self])
    }
}
