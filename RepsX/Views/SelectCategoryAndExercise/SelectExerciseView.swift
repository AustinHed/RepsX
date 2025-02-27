
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
    
    //Adding an exercise
    @State var isAddingExercise: Bool = false
    
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
                }
                .foregroundStyle(.black)
                
            }

        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        //MARK: Toolbar
        .toolbar {
            // Back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            //add exercise
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //action - open the "add Exercise" view
                    isAddingExercise.toggle()
                    
                } label: {
                    Image(systemName:"plus.circle")
                }
            }
        }
        //MARK: Sheets
        .sheet(isPresented: $isAddingExercise) {
            CreateNewExerciseTemplateView(category: category)
        }
    }
}
