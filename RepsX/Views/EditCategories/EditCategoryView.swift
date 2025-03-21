//
//  AddCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI
import SwiftData

struct EditCategoryView: View {
    
    //the category you want to edit
    @State var category: CategoryModel
    
    //query for all exercises for a category
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    //view model
    private var categoryViewModel:CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    //view model
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    @State var exercises: [ExerciseTemplate] = []
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack{

            List{
                //update name
                Section("Name"){
                    if category.standard {
                        Text(category.name)
                    } else {
                        TextField("Category", text: $category.name)
                            .onSubmit {
                                categoryViewModel.updateCategory(category, newName: category.name)
                            }
                            .foregroundStyle(.black)
                    }
                }
                
                //Exercises
                if !exercises.isEmpty {
                    Section("Exercises") {
                        ForEach(exercises){ exercise in
                            if exercise.category == category {
                                NavigationLink(exercise.name) {
                                    EditExerciseTemplateView(exerciseTemplate: exercise)
                                }
                            }
                        }
                    }
                }
                
                
                //delete button
                if category.standard{
                    //nothing
                } else {
                    Section() {
                        Button("Delete"){
                            categoryViewModel.deleteCategory(category)
                            dismiss()
                        }
                        .disabled(!exercises.isEmpty)
                        .foregroundStyle(.red)
                    } footer: { Text("To delete a custom category, first ensure there are no exercises in the category") }
                }

            }
            .navigationTitle(Text(category.standard ? "View Category" : "Edit Category"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            //MARK: Toolbar
            .toolbar {
                //Back button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundStyle(userThemeViewModel.primaryColor)
                }
            }
            //MARK: On Appear
            .onDisappear {
                exercises = []
            }
            .onAppear {
                let newCategories = exerciseTemplateViewModel.fetchExercisesForCategory(category: category)
                    .filter { newCategory in
                        // Replace `id` with the unique property or ensure CategoryModel is Equatable
                        !exercises.contains(where: { $0.id == newCategory.id })
                    }
                exercises.append(contentsOf: newCategories)
            }
        }
        
    }
}
