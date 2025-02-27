//
//  SelectCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.
//

import SwiftUI
import SwiftData
import Foundation

struct SelectCategoryView: View {
    
    //dismiss var
    @Binding var isSelectingExercise: Bool
    var onExerciseSelected: (ExerciseTemplate) -> Void
    
    //Fetch categories
    @Query(sort: \CategoryModel.name) var categories: [CategoryModel]
    @Environment(\.modelContext) private var modelContext
    

    //View Model - category
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    //View Model - exerciseTemplate
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //toggles
    @State var isAddingExercise: Bool = false
    @State var isEditingCategories:Bool = false
    
    //environment and context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: SelectExerciseView(
                        category: category,
                        isSelectingExercise: $isSelectingExercise,
                        onExerciseSelected: onExerciseSelected
                    )) {
                        Text(category.name)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar{
                //cancel button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                //add exercise view
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingExercise.toggle()
                    } label: {
                        Image(systemName:"plus.circle")
                    }
                }
                //edit exercises and categories
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Edit Exercises") {
                            //move into edit exercises view
                        }
                        Button("Edit Categories") {
                            //move into edit categories view
                            isEditingCategories.toggle()
                        }
                    } label: {
                        Image(systemName:"ellipsis.circle")
                    }
                }
            }
            //MARK: Sheets
            .sheet(isPresented: $isAddingExercise) {
                CreateNewExerciseTemplateView()
            }
            .sheet(isPresented: $isEditingCategories) {
                ListOfCategoriesView()
            }
        }
        
    }
}
