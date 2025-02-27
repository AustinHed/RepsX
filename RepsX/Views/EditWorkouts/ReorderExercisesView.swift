//
//  ReorderExercisesView.swift
//  RepsX
//
//  Created by Austin Hed on 2/24/25.
//

import SwiftUI

struct ReorderExercisesView: View {
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    //view model
    let workoutViewModel: WorkoutViewModel
    //workout to move
    var workout: Workout
    
    // Local state to hold the ordered exercises for reordering
    @State private var orderedExercises: [Exercise] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(orderedExercises) { exercise in
                    Text(exercise.name)
                }
                .onMove(perform: moveExercise)
            }
            // Force editing mode so drag handles are visible immediately.
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
                }
                // Done button on the right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        updateExerciseOrder()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Populate local state with the workout's exercises, sorted by their current order.
            orderedExercises = workout.exercises.sorted { $0.order < $1.order }
        }
    }
    
    //MARK: Local Functions
    // Called when the user drags to reorder the exercises.
    func moveExercise(from source: IndexSet, to destination: Int) {
        orderedExercises.move(fromOffsets: source, toOffset: destination)
    }
    
    // Update the workout's exercises with the new order.
    func updateExerciseOrder() {
        // Update the order property of each exercise based on its new index.
        for (index, exercise) in orderedExercises.enumerated() {
            exercise.order = index
        }
        // Reassign the updated, ordered list back to the workout.
        workout.exercises = orderedExercises
        // Save the changes to persist the new ordering.
        workoutViewModel.save()
    }
}

