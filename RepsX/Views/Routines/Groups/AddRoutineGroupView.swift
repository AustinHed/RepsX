//
//  AddRoutineGroupView.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData
import Foundation

struct AddNewRoutineGroupView: View {
    //Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //view models
    private var routineGroupViewModel: RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    @State var name: String = ""
    
    var body: some View {
        NavigationStack{
            List {
                HStack{
                    Text("Name")
                    Spacer()
                    TextField("New Group", text: $name)
                        .multilineTextAlignment(.trailing)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Add New Group")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar {
                //close button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                //Save button
                ToolbarItem(placement:.topBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty {
                            routineGroupViewModel.addRoutine(name: name)
                            dismiss()
                        }
                    }
                    .disabled(!name.isEmpty)
                }
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
        }
    }
}
