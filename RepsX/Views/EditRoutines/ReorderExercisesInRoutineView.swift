//
//  ReorderExercisesInRoutineView.swift
//  RepsX
//
//  Created by Austin Hed on 4/29/25.
//

import SwiftUI

struct ReorderExercisesInRoutineView: View {
    //dismiss
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    //routine to edit
    var routine: Routine
    
    //vm
    let exerciseInRoutineViewModel: ExerciseInRoutineViewModel
    
    @State private var orderedExercises: [ExerciseInRoutine] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(orderedExercises){ exercise in
                    Text(exercise.exerciseTemplate?.name ?? "Unknown Exercise")
                }
                .onMove(perform: moveExercise)
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Reorder Exercises")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar {
                // Cancel button on the left
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(themeColor)
                }
                // Done button on the right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        updateExerciseOrder()
                        dismiss()
                    }
                    .foregroundStyle(themeColor)
                }
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(themeColor: themeColor)
            )
            
        }
        .onAppear {
            //populate the local state with the exercises in the Routine
            orderedExercises = routine.exercises.sorted {$0.order < $1.order}
        }

    }
    
    
    //MARK: Local functions
    func moveExercise(from source: IndexSet, to destination: Int){
        orderedExercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateExerciseOrder() {
        //update index property
        for (index, exercise) in orderedExercises.enumerated() {
            exercise.order = index
        }
        //update the routine array
        routine.exercises = orderedExercises
        //save changes to context
        exerciseInRoutineViewModel.save()
        
    }
}
