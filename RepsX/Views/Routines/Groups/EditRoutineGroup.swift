//
//  EditRoutineGroup.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData

struct EditRoutineGroup: View {
    let routineGroup: RoutineGroup
    @State private var groupName: String
    
    @State private var isDeleteConfirmationPresented = false
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
    
    init(routineGroup: RoutineGroup) {
        self.routineGroup = routineGroup
        _groupName = State(initialValue: routineGroup.name)
    }
    
    var body: some View {
        List {
            //update name
            Section("Name"){
                TextField("Name", text: $groupName)
                    .onSubmit {
                        routineGroupViewModel.updateRoutineGroup(routineGroup, newName: groupName)
                    }
                    .foregroundStyle(Color.primary)
            }
            //delete
            Section(){
                Button("Delete") {
                    isDeleteConfirmationPresented = true
                }
                .foregroundStyle(.red)
                .confirmationDialog(
                    "Are you sure you want to delete this group?",
                    isPresented: $isDeleteConfirmationPresented,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        dismiss()
                        
                        routineGroupViewModel.deleteRoutineGroup(routineGroup)
                        
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .navigationTitle(Text("Edit Group"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        //MARK: Toolbar
        .toolbar {
            //Back button
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .disabled(routineGroup.name.isEmpty)
            }
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
    }
}
