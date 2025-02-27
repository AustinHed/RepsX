//
//  AddCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI

struct EditCategoryView: View {
    
    //the category you want to edit
    @State var category: CategoryModel
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    private var categoryViewModel:CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack{
            List{
                //update name
                Section("Category Name"){
                    TextField("Category", text: $category.name)
                    // Called when the user taps Return
                        .onSubmit {
                            categoryViewModel.updateName(category, newName: category.name)
                        }
                        .foregroundStyle(.black)
                    
                }
                
                //delete button
                Section() {
                    Button("Delete"){
                        //TODO: Fix how deletes work, currently causes a crash
//                        categoryViewModel.deleteCategory(category)
//                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("Edit Category"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Add a custom back button with a static label "Back".
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
        
    }
}

#Preview {
    
    let category:CategoryModel = CategoryModel(name: "Chest")
    @Environment(\.modelContext) var modelContext
    let categoryViewModel:CategoryViewModel = CategoryViewModel(modelContext: modelContext)
    //EditCategoryView(category: category, categoryViewModel: categoryViewModel)
}
