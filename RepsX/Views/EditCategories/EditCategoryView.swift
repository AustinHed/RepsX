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
                        //one option - just prevent delete if there are exercises associated
                        //would need to show all associated Exercises
                        //other option - hide lmao
//                        categoryViewModel.deleteCategory(category)
//                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("Edit Category"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            //MARK: Toolbar
            .toolbar {
                //Back button
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
