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
    
    //model context
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //view models
    private var categoryViewModel:CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    @State var exercises: [ExerciseTemplate] = []
    var standardExercises: [ExerciseTemplate] {
        exercises.filter { $0.standard }
    }
    var customExercises: [ExerciseTemplate] {
        exercises.filter { !$0.standard }
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    
    var body: some View {
        
        List{
            //update name
            Section(header:
                        HStack{
                Text("Name")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ){
                if category.standard {
                    Text(category.name)
                } else {
                    TextField("Category", text: $category.name)
                        .onSubmit {
                            categoryViewModel.updateCategory(category, newName: category.name)
                        }
                        .foregroundStyle(Color.primary)
                }
            }
            
            //Standard Exercises
            if !standardExercises.isEmpty {
                Section("Standard Exercises") {
                    ForEach(standardExercises){ exercise in
                        if exercise.category == category && exercise.standard == true {
                            NavigationLink(exercise.name, value: exercise)
                        }
                    }
                }
            }
            
            //Custom Exercises
            if !customExercises.isEmpty {
                Section("Custom Exercises") {
                    ForEach(customExercises){ exercise in
                        if exercise.category == category {
                            NavigationLink(exercise.name, value: exercise)
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
        //MARK: Destination
        .navigationDestination(for: ExerciseTemplate.self) { exercise in
            EditExerciseTemplateView(exerciseTemplate: exercise)
        }
        //MARK: Toolbar
        .toolbar {
            //Back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
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
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
        //MARK: Other
        .navigationBarBackButtonHidden(true)
        
    }
}
