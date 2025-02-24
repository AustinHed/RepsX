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
    @FocusState var isKeyboardActive: Bool //to dismiss the keyboard
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
                setWeightField(for: set)
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

extension ExerciseSectionView {
    /// Returns an editable weight field view for a given set.
    func setWeightField(for set: Set) -> some View {
        VStack(alignment: .leading) {
            Text("Lbs")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("0", text: Binding(
                get: {
                    let formatted = String(format: "%.0f", set.setWeight)
                    return formatted == "0" ? "" : formatted
                },
                set: { newValue in
                    if newValue.isEmpty {
                        set.setWeight = 0
                    } else if let number = Double(newValue) {
                        set.setWeight = number
                    } else {
                        set.setWeight = 0
                        print("the setWeight value was invalid")
                    }
                }
            ))
            .focused($isKeyboardActive)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateWeight(set, newWeight: set.setWeight)
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    let newWorkout = Workout(id: UUID(), startTime: Date())
    let newExercise = Exercise(name: "Bench Press", category: .chest, workout: newWorkout)
    List {
        ExerciseSectionView(exercise: newExercise)
    }
    
}
