//
//  ListOfRoutineGroups.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData
import Foundation

struct ListOfRoutineGroups: View {
    
    //Query
    @Query(sort: \RoutineGroup.name) var groups: [RoutineGroup]
    
    //Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresentedModally) private var isPresentedModally
    
    //view models
    private var routineGroupViewModel: RoutineGroupViewModel {
        RoutineGroupViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //to add
    @State private var isAddingGroup: Bool = false
    //to delete
    @State private var groupToDelete: RoutineGroup?
    @State private var isDeleteConfirmationPresented = false
    
    //to edit names
    @State private var groupBeingEdited: RoutineGroup?
    @State private var editedName: String = ""
    
    var body: some View {
        List {
            ForEach(groups) { group in
                if !group.name.isEmpty {
                    NavigationLink(value: group) {
                        Text(group.name)
                    }
                }
            }
//            ForEach(groups) { group in
//                NavigationLink(value: group) {
//                    Text(group.name)
//                }
//            }
        }
        .navigationTitle(Text("Routine Groups"))
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Toolbar
        .toolbar {
            //close button
            ToolbarItem(placement: .topBarLeading) {
                if isPresentedModally {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement:.topBarTrailing) {
                Button {
                    isAddingGroup.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                }
                
            }
        }
        //MARK: Navigation Link
        .navigationDestination(for: RoutineGroup.self) { group in
            EditRoutineGroup(routineGroup: group)
        }
        //MARK: Sheets
        .sheet(isPresented: $isAddingGroup) {
            AddNewRoutineGroupView()
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
    }
}





struct IsPresentedModallyKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPresentedModally: Bool {
        get { self[IsPresentedModallyKey.self] }
        set { self[IsPresentedModallyKey.self] = newValue }
    }
}

extension View {
    func presentedModally(_ isPresented: Bool) -> some View {
        environment(\.isPresentedModally, isPresented)
    }
}
