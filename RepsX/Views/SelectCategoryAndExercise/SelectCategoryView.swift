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
    
    //View Models
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //toggles
    @State var isAddingExercise: Bool = false
    //@State var isEditingCategories:Bool = false
    @State private var showEditCategories = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header:
                            HStack{
                    Text("Default Categories")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ) {
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
                    ) {
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
                        Button("Edit Categories") {
                            showEditCategories.toggle()
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
//            .sheet(isPresented: $isEditingCategories) {
//                ListOfCategoriesView(navigationTitle: "Edit Categories") { category in
//                    EditCategoryView(category: category)
//                }
//            }
            .sheet(isPresented: $showEditCategories) {
                NavigationStack {
                    ListOfCategoriesView(
                        navigationTitle: "Edit Categories",
                        isPresentedModally: true
                    ) { category in
                        EditCategoryView(category: category)
                    }
                }
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
        }
        
    }
}
