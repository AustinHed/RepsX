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
    
    //View Model
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
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
    
    //used to show the cancel button when shown as a modal
    let isPresentedModally: Bool
    
    init(
        navigationTitle: String,
        isPresentedModally: Bool = false,
        allWorkouts: [Workout]? = nil,
        @ViewBuilder destinationBuilder: @escaping (CategoryModel) -> Destination
    ) {
        self.navigationTitle = navigationTitle
        self.isPresentedModally = isPresentedModally
        self.allWorkouts = allWorkouts
        self.destinationBuilder = destinationBuilder
    }
    
    var body: some View {
        List {
            //default
            Section (header:
                        HStack{
                Text("Standard Categories")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ){
                ForEach(standardCategories) { category in
                    NavigationLink(category.name, value: category)
                }
            }
            
            //custom
            if !customCategories.isEmpty {
                Section(header:
                            HStack{
                    Text("Custom Categories")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ){
                    ForEach(customCategories) { category in
                        NavigationLink(category.name, value: category)
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Destination
        .navigationDestination(for: CategoryModel.self) { category in
            destinationBuilder(category)
        }
        //MARK: Toolbar
        .toolbar {
            if isPresentedModally {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingNewCategory.toggle()
                } label: {
                    Image(systemName: "plus.circle")
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
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
    }
}

//#Preview {
//    ListOfCategoriesView()
//        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
//}
