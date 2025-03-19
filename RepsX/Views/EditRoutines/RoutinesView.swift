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
    @Query(sort: \Routine.name, order: .forward) var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    //routines view model
    private var routineViewModel:RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //new routine AND toggle to invoke navigation link
    @State private var newRoutine: Routine? = nil
    @State private var isLinkActive = false
    
    //Routing around
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(routines) { routine in
                    NavigationLink {
                        EditRoutine(routine: routine, selectedTab: $selectedTab)
                    } label: {
                        RoutineLabel(routine: routine, color: userThemeViewModel.primaryColor)
                    }
                    //MARK: Swipe Actions
                    .swipeActions(edge: .trailing) {
                        deleteSwipeAction(for: routine)
                    }
                }
            }
            .navigationTitle("Routines")
            //MARK: Toolbar
            .toolbar {
                //Plus button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //action
                        newRoutine = routineViewModel.addRoutine(name: "New Routine")
                        isLinkActive = true
                    } label: {
                        Image(systemName:"plus.circle")
                    }
                }
                
                
            }
            .background(
                NavigationLink(
                    destination: Group {
                        if let routine = newRoutine {
                            AddNewRoutineView(routine: routine)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $isLinkActive,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
        }
        .tint(userThemeViewModel.primaryColor)
    }
}

//MARK: Star for routines
extension RoutinesView{
    struct RoutineLabel: View {
        let routine: Routine
        let color:Color
        
        var body: some View {
            Group {
                if routine.favorite {
                    HStack {
                        Text(routine.name)
                        Spacer()
                        // If you're using SF Symbols, use systemName
                        Image(systemName: "star.fill")
                            .foregroundStyle(color)
                    }
                } else {
                    Text(routine.name)
                }
            }
        }
    }
}

//MARK: Swipe to delete
extension RoutinesView {
    private func deleteSwipeAction(for routine: Routine) -> some View {
        Button(role: .destructive) {
            routineViewModel.deleteRoutine(routine)
        } label: {
            Image(systemName: "trash.fill")
        }
        .tint(.red)
    }
}
