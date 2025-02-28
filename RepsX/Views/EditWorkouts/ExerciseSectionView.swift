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
        
        //sets
        ForEach(Array(exercise.sets.sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, set in
            ///display sets in order of set.order
            HStack  {
                
                //number
                exerciseNumberField(index: index, set: set)
                
                //weight
                setWeightField(for: set)
                
                //reps
                setRepsField(for: set)
                
                //Intensity
                notesView(set:set)
                
            }
            //MARK: Swipe Actions
            .swipeActions(edge: .trailing) {
                //delete
                Button("delete", role: .destructive) {
                    withAnimation{
                        exerciseViewModel.deleteSet(set, from: exercise)
                    }
                    
                }
                
            }
        }
        
        //add button
        addButton()
    }
    
}

//MARK: Set number
extension ExerciseSectionView {
    func exerciseNumberField(index:Int, set: Set) -> some View {
        Text("\(index + 1)")
            .font(.caption)
            .bold()
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .stroke(set.reps == 0 ? Color.gray : Color.blue,
                            lineWidth: 1.5
                           )
            )
            .padding(.trailing)
            .foregroundColor(set.reps == 0 ? Color.gray : Color.blue)
    }
}

//MARK: Weight
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
                        print("update setWeight with an empty value, use 0")
                    } else if let number = Double(newValue) {
                        set.setWeight = number
                        print("update setWeight with valid value")
                    } else {
                        set.setWeight = 0
                        print("update setWeight with invalid value, use 0")
                    }
                }
            ))
            .frame(maxWidth: 50, maxHeight: 15)
            .focused($isKeyboardActive)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateWeight(set, newWeight: set.setWeight)
            }
        }
        
    }
}
//MARK: Reps
extension ExerciseSectionView{
    func setRepsField(for set: Set) -> some View {
        VStack(alignment: .leading) {
            Text("Reps")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("0", text: Binding (
                get: {
                    let formatted = String(set.reps)
                    return formatted == "0" ? "" : formatted
                },
                set: { newValue in
                    if newValue.isEmpty {
                        set.reps = 0
                        print("update rep with an empty value, use 0")
                    } else if let number = Int(newValue) {
                        set.reps = number
                        print("update rep with valid value")
                    } else {
                        set.reps = 0
                        print("update reps with invalid value, use 0")
                    }
                }
            ))
            .frame(maxWidth: 50, maxHeight: 15)
            .focused($isKeyboardActive)
            .keyboardType(.numberPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateReps(set, newReps: set.reps)
            }
        }
        
    }
}

//MARK: Notes
extension ExerciseSectionView {
    func notesView(set:Set) -> some View {
        VStack(alignment:.leading){
            Text("Intensity")
                .font(.caption)
                .foregroundStyle(.secondary)
            IntensityBar(set: set)
        }
        .padding(.horizontal,8)
        .frame(maxHeight: 5)
    }
    
}

//MARK: Add Button
extension ExerciseSectionView {
    func addButton() -> some View {
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
    let newSet = Set(exercise: newExercise, reps: 10, weight: 10, intensity: 3)
    //newExercise.sets.append(newSet)
    
    List {
        Text("Workout")
            .bold()
        ExerciseSectionView(exercise: newExercise)
    }
    
}
