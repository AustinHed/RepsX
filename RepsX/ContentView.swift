//
//  ContentView.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            //Log
            LogView()
                .globalKeyboardDoneButton()
                .tabItem {
                    Label("Log", systemImage: "list.bullet")
                }
            
            //Routines
            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "list.bullet.rectangle")
                }
            
            //Stats
            Text("StatsView")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            //Settings
            Text("SettingsView")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
}
