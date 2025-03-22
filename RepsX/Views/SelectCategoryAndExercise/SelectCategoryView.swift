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
    
    //Dismiss
    @Binding var isSelectingExercise: Bool
    var onExerciseSelected: (ExerciseTemplate) -> Void
    
    //Queries
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == true &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var standardCategories: [CategoryModel]
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == false &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var customCategories: [CategoryModel]
    
    //Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    //View Models
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //toggles
    @State var isAddingExercise: Bool = false
    @State var isEditingCategories:Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Default Categories") {
                    ForEach(standardCategories) { category in
                        NavigationLink(destination: SelectExerciseView(
                            category: category,
                            isSelectingExercise: $isSelectingExercise,
                            onExerciseSelected: onExerciseSelected
                        )) {
                            Text(category.name)
                        }
                    }
                }
                
                if !customCategories.isEmpty {
                    Section("Custom Categories") {
                        ForEach(customCategories) { category in
                            NavigationLink(destination: SelectExerciseView(
                                category: category,
                                isSelectingExercise: $isSelectingExercise,
                                onExerciseSelected: onExerciseSelected
                            )) {
                                Text(category.name)
                            }
                        }
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
                        NavigationLink("Edit Categories") {
                            ListOfCategoriesView(navigationTitle: "Edit Categories") { category in
                                EditCategoryView(category: category)
                            }
                        }
                    } label: {
                        Image(systemName:"ellipsis.circle")
                    }
                }
            }
            //MARK: Sheets
            .sheet(isPresented: $isAddingExercise) {
                AddNewExerciseTemplateView()
            }
            .sheet(isPresented: $isEditingCategories) {
                ListOfCategoriesView(navigationTitle: "Edit Categories") { category in
                    EditCategoryView(category: category)
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
