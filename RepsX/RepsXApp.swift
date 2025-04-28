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
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .globalKeyboardDoneButton()
                .environment(ThemeManager(modelContext: modelContext))
        }
        .modelContainer(for: [
            Workout.self,
            Exercise.self,
            Set.self,
            ExerciseTemplate.self,
            CategoryModel.self,
            Routine.self,
            ExerciseInRoutine.self,
            UserTheme.self,
            ConsistencyGoal.self,
            TargetGoal.self
        ]
        )
        
    }
}
