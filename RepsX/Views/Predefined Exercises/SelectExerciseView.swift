
//  SelectExerciseView.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.


import SwiftUI
import SwiftData
import Foundation

struct SelectExerciseView: View {
    
    //takes selected category
    let category: CategoryModel
    
    //the dismiss
    @Binding var isSelectingExercise: Bool
    
    //the passable onSelect
    var onExerciseSelected:(PredefinedExercise) -> Void
    
    // Query all predefined exercises, sorted by name.
    @Query(sort: \PredefinedExercise.name) var allExercises: [PredefinedExercise]
    
    var filteredExercises: [PredefinedExercise] {
        allExercises.filter { $0.category.id == category.id }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        List(filteredExercises){ exercise in
            Button {
                onExerciseSelected(exercise)
                isSelectingExercise = false
            } label: {
                HStack{
                    Text(exercise.name)
                    Spacer()
                    Text(exercise.category.name)
                }
                
            }

        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)

//        NavigationStack{
//            List {
//                ForEach(filteredExercises) { exercise in
//                    Text(exercise.name)
//                }
//            }
//            .navigationTitle(chosenCategory.name)
//            .navigationBarTitleDisplayMode(.inline)
//        }
    }
}


//#Preview {
//
//    let defaultExercises = [
//    ]
//
//    let testCategory = CategoryModel(name: "Test Category")
//    SelectExerciseView(category: testCategory)
//        .modelContainer(for: [Workout.self, Exercise.self, Set.self, PredefinedExercise.self, CategoryModel.self])
//
//
//}
