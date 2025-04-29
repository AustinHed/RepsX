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
    var standardCategories: [CategoryModel] {
        categories.filter {$0.standard == true}
    }
    var customCategories: [CategoryModel] {
        categories.filter {$0.standard == false}
    }
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //view model
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var exerciseTemplate:ExerciseTemplate
    
    var body: some View {
        List {
            Section("Standard Categories") {
                ForEach(standardCategories){ cat in
                    Button {
                        exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newCategory: cat)
                        dismiss()
                    } label: {
                        categoryLabel(for: cat)
                    }
                }
            }
            
            if !customCategories.isEmpty{
                Section("Custom Categories"){
                    ForEach(customCategories) { cat in
                        Button {
                            exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newCategory: cat)
                            dismiss()
                        } label: {
                            categoryLabel(for: cat)
                        }
                    }
                }
            }
        }
        .navigationTitle("Choose category")
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
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
                    .foregroundStyle(primaryColor)
            }
        } else {
            Text(category.name)
                .foregroundStyle(.black)
        }
    }
}
