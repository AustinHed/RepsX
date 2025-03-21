////
////  ContentView.swift
////  RepsX
////
////  Created by Austin Hed on 2/17/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    
//    @State private var selectedTab: Tab = .history
//        
//        enum Tab {
//            case history, routines, stats, settings
//        }
//    
//    @Environment(\.modelContext) private var modelContext
//    
//    //View Model
//    private var userThemeViewModel: UserThemeViewModel {
//        UserThemeViewModel(modelContext: modelContext)
//    }
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            //Log
////            WorkoutHistoryView(selectedTab: $selectedTab)
////                .globalKeyboardDoneButton()
////                .tabItem {
////                    Label("History", systemImage: "list.bullet")
////                }
////                .tag(Tab.history)
//            
//            //Routines
////            RoutinesView(selectedTab: $selectedTab)
////                .tabItem {
////                    Label("Routines", systemImage: "list.bullet.rectangle")
////                }
////                .tag(Tab.routines)
////            
////            //Stats
////            StatsHomeView(selectedTab: $selectedTab)
////                .tabItem {
////                    Label("Stats", systemImage: "chart.bar")
////                }
////                .tag(Tab.stats)
////            
////            //Settings
////            SettingsView(selectedTab: $selectedTab)
////                .tabItem {
////                    Label("Settings", systemImage: "gear")
////                }
////                .tag(Tab.settings)
//        }
//        
//        .onChange(of: userThemeViewModel.primaryColor) { newColor in
//            UITabBar.appearance().tintColor = UIColor(newColor)
//        }
//        .id(userThemeViewModel.primaryColor.hashValue)
//        .tint(userThemeViewModel.primaryColor)
//        
//    }
//}
//
//
//#Preview {
//    ContentView()
//        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
//}
