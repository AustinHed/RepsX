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
    
    //queries
    @Query(sort: \Routine.name, order: .forward) var routines: [Routine]
    @Query(sort: \RoutineGroup.name, order: .forward) private var routineGroups: [RoutineGroup]
    
    @Environment(\.modelContext) private var modelContext
    
    //routines view model
    private var routineViewModel:RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //new routine AND toggle to invoke navigation link
    @State private var newRoutine: Routine? = nil
    @State private var isLinkActive = false
    
    @State private var expandedGroups: [UUID] = []
    @State private var isUngroupedExpanded: Bool = true
    
    //all favorite routines
    private var favorites: [Routine] {
        routines.filter { $0.favorite }
    }

    //all routines in a given group
    private func routines(in group: RoutineGroup) -> [Routine] {
        routines.filter { $0.group?.id == group.id }
    }

    //all routines without a group
    private var ungroupedRoutines: [Routine] {
        routines.filter { $0.group == nil && !$0.favorite }
    }
    
    //Routing around
    @Binding var selectedTab: ContentView.Tab
    
    let columns = [
        GridItem(.flexible(minimum: 160), spacing: 15),
        GridItem(.flexible(minimum: 160), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            routineList
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
            CustomBackground(primaryColor: primaryColor)
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
        .tint(primaryColor)
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
        
        
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

//MARK: Add Button
extension RoutinesView {
    private var addButton: some View {
        Button {
            newRoutine = routineViewModel.addRoutine(name: "New Routine")
            isLinkActive = true
        } label: {
            VStack{
                Spacer()
                Image(systemName:"plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(primaryColor)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(minHeight: 140)
        }
    }
}

//MARK: Routine List
extension RoutinesView {
    
    private var routineList: some View {
        VStack(spacing: 20) {
            favoritesSection
            groupedRoutineSections
            ungroupedSection
            addButton.padding(.horizontal, 15)
        }
    }

    private var favoritesSection: some View {
        Group {
            if !favorites.isEmpty {
                VStack(alignment: .leading) {
                    Text("Favorites")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(favorites) { routine in
                            NavigationLink(value: routine) {
                                RoutineItem(routine: routine)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }

    private var groupedRoutineSections: some View {
        ForEach(routineGroups) { group in
            let binding = Binding(
                get: { expandedGroups.contains(group.id) },
                set: { newValue in
                    if newValue {
                        expandedGroups.append(group.id)
                    } else {
                        expandedGroups.removeAll { $0 == group.id }
                    }
                }
            )
            SectionView(
                title: group.name,
                routines: routines(in: group),
                isExpanded: binding,
                columns: columns
            )
        }
    }

    private var ungroupedSection: some View {
        Group {
            if !ungroupedRoutines.isEmpty {
                let binding = $isUngroupedExpanded
                SectionView(
                    title: "Ungrouped",
                    routines: ungroupedRoutines,
                    isExpanded: binding,
                    columns: columns
                )
            }
        }
    }

    private var navigationLinkBackground: some View {
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
    }
}

#Preview{
    RoutinesView(selectedTab: .constant(.routines))
}
