//
//  AddNewCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI

struct AddNewCategoryView: View {
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) private var dismiss
    
    //view model
    private var categoryViewModel:CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    //name to edit
    @State private var newName:String = ""
    
    var body: some View {
        NavigationStack{
            List{
                Section(header:
                            HStack{
                    Text("Name")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ){
                    TextField("Category Name", text: $newName)
                }
            }
            .navigationTitle(Text("Create a New Category"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            //MARK: Toolbar
            .toolbar {
                //cance; button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeColor)
                }
                //save button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        categoryViewModel.addCategory(name: newName)
                        dismiss()
                    }
                    .foregroundStyle(newName.isEmpty ? Color.gray: themeColor)
                    .disabled(Bool(newName.isEmpty))
                }
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(themeColor: themeColor)
            )
        }
    }
}
