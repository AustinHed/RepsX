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
    
    var body: some Scene {
        
        WindowGroup {
            LogView()
                .globalKeyboardDoneButton()
        }
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, PredefinedExercise.self, CategoryModel.self])
    }
}
