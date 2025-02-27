//
//  EditCategoriesView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI
import SwiftData

struct ListOfCategoriesView: View {
    
    //Fetch categories
    @Query(sort: \CategoryModel.name) var categories: [CategoryModel]
    @Environment(\.modelContext) private var modelContext
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    //View Model
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    //selected category
    @State private var selectedCategory:CategoryModel? = nil
    
    //Add new category
    @State private var isAddingNewCategory: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.name)
                            .foregroundStyle(.black)
                    }

                }
            }
            .navigationTitle("Edit Categories")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbars
            .toolbar{
                //cancel button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //TODO: Add a new category function
                        isAddingNewCategory.toggle()
                    } label: {
                        Image(systemName:"plus.circle")
                    }

                }
            }
            //MARK: Sheets
            //edit category
            .sheet(item: $selectedCategory) { category in
                EditCategoryView(category: category)
            }
            //add new category
            .sheet(isPresented: $isAddingNewCategory) {
                AddNewCategoryView()
            }
        }
    }
}

#Preview {
    ListOfCategoriesView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
}
