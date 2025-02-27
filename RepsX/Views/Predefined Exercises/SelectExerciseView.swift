
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
    var onExerciseSelected:(ExerciseTemplate) -> Void
    
    // Query all predefined exercises, sorted by name.
    @Query(sort: \ExerciseTemplate.name) var allExercises: [ExerciseTemplate]
    
    var filteredExercises: [ExerciseTemplate] {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Add a custom back button with a static label "Back".
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //add a new Exercise, with the category already defined based on the "category" above
                } label: {
                    Image(systemName:"plus.circle")
                }

            }
        }
    }
}
