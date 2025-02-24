//
//  ExerciseSectionView.swift
//  RepsX
//
//  Created by Austin Hed on 2/23/25.
//

import SwiftUI

struct ExerciseSectionView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    //initialized Exercise
    @State var exercise: Exercise
    
    //viewModel
    private var exerciseViewModel: ExerciseViewModel {
        ExerciseViewModel(modelContext: modelContext)
    }
    
    //focus states
    @FocusState private var setWeightFocused: Bool
    
    //body
    var body: some View {
        //name
        Text(exercise.name)
            .font(.headline)
        
        //sets
        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
            HStack {
                //number
                Text("\(index + 1)")
                    .font(.caption)
                    .bold()
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.blue))
                    .foregroundColor(.white)
                
                //editable weight
                VStack(alignment:.leading){
                    Text("Lbs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Weight", text: Binding(
                        get: { String(format: "%.0f", set.setWeight) },
                        set: { newValue in
                            if let number = Double(newValue) {
                                set.setWeight = number
                            }
                        }
                    ))
                    .keyboardType(.decimalPad)
                    .submitLabel(.done)
                    .onSubmit {
                        //update the actual setWeight for the set
                        exerciseViewModel.updateWeight(set, newWeight: set.setWeight)
                    }
                }
                .padding(.horizontal,8)
                
                //reps
                VStack(alignment:.leading){
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(set.reps.description)
                    //.bold()
                }
                .padding(.horizontal,8)
                
                //notes
                VStack(alignment:.leading){
                    Text("Notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(".")
                }
                .padding(.horizontal,8)
            }
        }
        
        //add button
        Button {
            exerciseViewModel.addSet(to: exercise, reps: 0, weight: 0)
        } label: {
            Text("Add Set")
        }
    }
}

#Preview {
    let newWorkout = Workout(id: UUID(), startTime: Date())
    let newExercise = Exercise(name: "Bench Press", category: .chest, workout: newWorkout)
    List {
        ExerciseSectionView(exercise: newExercise)
    }
    
}
