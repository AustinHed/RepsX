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
    
    @Environment(\.themeColor) var themeColor
    @Environment(\.modelContext) private var modelContext
    
    //routines view model
    private var routineViewModel:RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //new routine AND toggle to invoke navigation link
    @State private var newRoutine: Routine? = nil
    @State private var isLinkActive = false
    
    //Routing around
    @Binding var selectedTab: ContentView.Tab
    
    let columns = [
        GridItem(.flexible(minimum: 160), spacing: 15),
        GridItem(.flexible(minimum: 160), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                //Routines
                ForEach(routines) { routine in
                    NavigationLink(value: routine) {
                        RoutineItem(routine: routine)
                    }
                    //favorite and delete
                    .contextMenu {
                        //favorite
                        Button {
                            routineViewModel.favoriteRoutine(routine)
                        } label: {
                            HStack{
                                Text("Favorite")
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName:"star.circle.fill")
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        //delete
                        Button(role: .destructive) {
                            withAnimation {
                                routineViewModel.deleteRoutine(routine)
                            }
                        } label: {
                            HStack{
                                Text("Delete")
                                    .foregroundStyle(.red)
                                Spacer()
                                Image(systemName:"trash.fill")
                                    .foregroundStyle(.red)
                            }
                        }                        
                    }
                }
                
                //Add button
                Button {
                    newRoutine = routineViewModel.addRoutine(name: "New Routine")
                    isLinkActive = true
                } label: {
                    VStack{
                        Spacer()
                        Image(systemName:"plus.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(themeColor)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .frame(minHeight: 140)
                }
            }
            
            .padding(.horizontal, 15)
        }
        .navigationTitle("Routines")
        //MARK: Destination
        .navigationDestination(for: Routine.self, destination: { routine in
            EditRoutine(routine: routine, selectedTab: $selectedTab )
        })
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
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
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
        .tint(themeColor)
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

