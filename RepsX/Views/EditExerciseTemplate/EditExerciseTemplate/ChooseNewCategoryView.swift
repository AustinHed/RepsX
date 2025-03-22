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
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var categories: [CategoryModel]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
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
    
    
    //this creates the list of categories to select from
    @ViewBuilder
    private func categoryLabel(for category: CategoryModel) -> some View {
        if exerciseTemplate.category == category {
            HStack {
                Text(category.name)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(themeColor)
            }
        } else {
            Text(category.name)
                .foregroundStyle(.black)
        }
    }
}
