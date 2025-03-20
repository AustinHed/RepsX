//
//  ChooseNewCategoryView.swift
//  RepsX
//
//  Created by Austin Hed on 3/19/25.
//

import SwiftUI
import SwiftData

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
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    var exerciseTemplate:ExerciseTemplate
    
    var body: some View {
        NavigationStack {
            List(categories) { category in
                Button {
                    exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newCategory: category)
                    dismiss()
                } label: {
                    categoryLabel(for: category, userThemeViewModel: userThemeViewModel)
                }
            }
            .navigationTitle("Choose category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    //this creates the list of categories to select from
    @ViewBuilder
    private func categoryLabel(for category: CategoryModel, userThemeViewModel: UserThemeViewModel) -> some View {
        if exerciseTemplate.category == category {
            HStack {
                Text(category.name)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(userThemeViewModel.primaryColor)
            }
        } else {
            Text(category.name)
                .foregroundStyle(.black)
        }
    }
}
