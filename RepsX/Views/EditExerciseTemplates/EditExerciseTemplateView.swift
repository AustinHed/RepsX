//
//  EditExerciseTemplateView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import SwiftData

struct EditExerciseTemplateView: View {
    
    //the category you want to edit
    @State var exerciseTemplate: ExerciseTemplate
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack{
            List{
                //update name
                Section("Edit exercise name"){
                    TextField("Exercise", text: $exerciseTemplate.name)
                        .onSubmit {
                            exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newName: exerciseTemplate.name)
                        }
                        .foregroundStyle(.black)
                    
                }
                
                //update category
                Section("Edit exercise category"){
                    NavigationLink(exerciseTemplate.category.name) {
                        ChooseNewCategoryView( exerciseTemplate: exerciseTemplate)
                    }
                }
                
                //delete button
                Section() {
                    Button("Delete"){
                        exerciseTemplateViewModel.deleteExerciseTemplate(exerciseTemplate)
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle(Text("Edit Exercise"))
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

//MARK: Choose a new category
struct ChooseNewCategoryView: View {
    //Fetch categories
    @Query(sort: \CategoryModel.name) var categories: [CategoryModel]
    @Environment(\.modelContext) private var modelContext
    //dismiss
    @Environment(\.dismiss) private var dismiss
    //view model
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    var exerciseTemplate:ExerciseTemplate
    
    var body: some View {
        NavigationStack {
            List(categories) { category in
                Button {
                    exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newCategory: category)
                    dismiss()
                } label: {
                    categoryLabel(for: category)
                }
            }
            .navigationTitle("Choose category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func categoryLabel(for category: CategoryModel) -> some View {
        if exerciseTemplate.category == category {
            HStack {
                Text(category.name)
                Spacer()
                Image(systemName: "checkmark")
            }
        } else {
            Text(category.name)
        }
    }
}

#Preview {
    let exerciseTemplate = ExerciseTemplate(name: "Test")
    EditExerciseTemplateView(exerciseTemplate: exerciseTemplate)
}
