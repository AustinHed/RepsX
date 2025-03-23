//
//  EditCategoriesView.swift
//  RepsX
//
//  Created by Austin Hed on 2/27/25.
//

import SwiftUI
import SwiftData

struct ListOfCategoriesView<Destination: View>: View {
    
    //Fetch standard categories
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == true &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var standardCategories: [CategoryModel]
    
    //Fetch custom categories
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == false &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var customCategories: [CategoryModel]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    //View Model
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    
    //selected category
    @State private var selectedCategory:CategoryModel? = nil
    
    //Add new category
    @State private var isAddingNewCategory: Bool = false
    
    // The title for the navigation bar.
    let navigationTitle: String
    
    //An optional list of all workouts
    let allWorkouts: [Workout]?
    
    // Closure that builds the destination iew for a given category.
    let destinationBuilder: (CategoryModel) -> Destination
    
    init(navigationTitle: String,
         allWorkouts: [Workout]? = nil,
         @ViewBuilder destinationBuilder: @escaping (CategoryModel) -> Destination) {
        self.navigationTitle = navigationTitle
        self.allWorkouts = allWorkouts
        self.destinationBuilder = destinationBuilder
    }
    
    var body: some View {
        NavigationStack {
            List {
                //default
                Section ("Standard Categories"){
                    ForEach(standardCategories) { category in
                        NavigationLink(category.name) {
                            destinationBuilder(category)
                        }
                    }
                }
                
                //custom
                if !customCategories.isEmpty {
                    Section("Custom Categories"){
                        ForEach(customCategories) { category in
                            NavigationLink(category.name) {
                                destinationBuilder(category)
                            }
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
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
                    .foregroundStyle(themeColor)

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
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(themeColor: themeColor)
            )
        }
        .tint(themeColor)
    }
}

//#Preview {
//    ListOfCategoriesView()
//        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
//}
