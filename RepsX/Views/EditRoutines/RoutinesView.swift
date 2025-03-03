//
//  RoutinesView.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import Foundation

struct RoutinesView: View {
    
    //Fetch all existing routines
    @Query(sort: \Routine.name, order: .reverse) var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    //routines view model
    private var routineViewModel:RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //Routing around
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        NavigationStack{
            List {
//favorites section
                ForEach(routines) { routine in
                    HStack{
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(UIColor(hex:routine.colorHex ?? "") ?? .gray))
                        NavigationLink(routine.name) {
                            EditRoutine(routine: routine, selectedTab: $selectedTab)
                        }
                    }
                    
                }
            }
            .navigationTitle("Routines")
            //MARK: Toolbar
            .toolbar {
                //Edit Button
                ToolbarItem(placement: .topBarLeading) {
                    Text("Edit")
                }
                
                //Plus button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //new Routine
                    } label: {
                        Image(systemName:"plus")
                    }

                }
            }
        }
    }
}

#Preview {
    RoutinesView(selectedTab: .constant(.routines))
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self])
}
