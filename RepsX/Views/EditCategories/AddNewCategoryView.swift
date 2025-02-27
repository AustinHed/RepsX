//
//  AddNewCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI

struct AddNewCategoryView: View {
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    //view model
    private var categoryViewModel:CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    //name to edit
    @State private var newName:String = ""
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            List{
                Section("Name"){
                    TextField("Category Name", text: $newName)
                }
            }
            .navigationTitle(Text("Create a New Category"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Add a custom back button with a static label "Back".
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        categoryViewModel.addCategory(name: newName)
                        dismiss()
                    }
                    .disabled(Bool(newName.isEmpty))
                }
            }
        }
        
        
    }
}

#Preview {
    AddNewCategoryView()
}
