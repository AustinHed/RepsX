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
    
    //add a passed ExerciseTemplate
    
    //Add new category
    @State private var isAddingNewCategory: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(category.name) {
                        EditCategoryView(category: category)
                    }
                    
//                    Button {
//                        selectedCategory = category
//                    } label: {
//                        Text(category.name)
//                            .foregroundStyle(.black)
//                    }

                }
            }
            .navigationTitle("Edit Categories")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar{
                //add new category
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
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
