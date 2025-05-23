//
//  EditRoutineGroup.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData

struct EditRoutineGroup: View {
    @State var routineGroup: RoutineGroup
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
    
    var body: some View {
        List {
            //update name
            Section("Name"){
                TextField("Name", text: $routineGroup.name)
                    .onSubmit {
                        routineGroupViewModel.updateRoutineGroup(routineGroup, newName: routineGroup.name)
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
                        routineGroupViewModel.deleteRoutineGroup(routineGroup)
                        dismiss()
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
