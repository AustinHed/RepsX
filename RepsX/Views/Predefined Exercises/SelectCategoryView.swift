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
    
    //dismiss var
    @Binding var isSelectingExercise: Bool
    var onExerciseSelected: (PredefinedExercise) -> Void
    //Fetch categories
    @Query(sort: \CategoryModel.name, order: .reverse) var categories: [CategoryModel]
    @Environment(\.modelContext) private var modelContext
    

    //View Model
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    //View Model
    private var predefinedExerciseViewModel: PredefinedExercisesViewModel {
        PredefinedExercisesViewModel(modelContext: modelContext)
    }
    
    
    //environment and context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: SelectExerciseView(
                        category: category,
                        isSelectingExercise: $isSelectingExercise,
                        onExerciseSelected: onExerciseSelected
                    )) {
                        Text(category.name)
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
            
            //test button to delete later
            Button {
                categoryViewModel.addCategory(name: "Chest")
                print("add category")
            } label: {
                Text("add CategoryModel")
            }
            
            Button {
                predefinedExerciseViewModel.addPredefinedExercise(name: "Bench", category: CategoryModel(id: UUID(), name: "Chest"))
            } label: {
                Text("add PredefinedWorkout model")
            }

        }
    }
}
