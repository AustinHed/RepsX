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
    //TODO: ensure there are default routines on app launch
    //TODO: local button to add routines to memory for this view
    @Query(sort: \Routine.name, order: .reverse) var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    //routines view model
    private var routineViewModel:RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack{
            List {
//                Section(header: Text("Favorites")) {
//                    ForEach(routines) {routine in
//                        if routine.favorite {
//                            Text(routine.name)
//                        }
//                    }
//                }
                
                ForEach(routines) { routine in
                    HStack{
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(UIColor(hex:routine.colorHex ?? "") ?? .gray))
                        NavigationLink(routine.name) {
                            EditRoutine(routine: routine)
                        }
                    }
                    
                }
                
                Section {
                    Button {
                        routineViewModel.addRoutine(name: "Test Routine")
                    } label: {
                        Text("Add test routines")
                    }
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                
                //Edit Button
                ToolbarItem(placement: .topBarLeading) {
                    Text("Edit")
                }
                
                //Plus button
                ToolbarItem(placement: .topBarTrailing) {
                    Text("plus")
                }
            }
        }
    }
}

#Preview {
    RoutinesView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self])
}
