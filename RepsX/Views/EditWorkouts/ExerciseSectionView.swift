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
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
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
                exerciseNumberField(index: index, set: set, primaryColor: userThemeViewModel.primaryColor)
                
                //weight
                if set.exercise?.modality == .repetition {
                    setWeightField(for: set)
                    setRepsField(for: set)
                } else if set.exercise?.modality == .tension {
                    setWeightField(for: set)
                    setTimeField(for: set)
                } else if set.exercise?.modality == .endurance {
                    setDistanceField(for: set)
                    setTimeField(for: set)
                } else {
                    setNotesField(for: set)
                }
                
                //Intensity
                intensityBar(set:set)
                
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
        addButton(primaryColor:userThemeViewModel.primaryColor)
    }
    
}

//MARK: Set number
extension ExerciseSectionView {
    //TODO: Make this a button?
    func exerciseNumberField(index:Int, set: Set, primaryColor:Color) -> some View {
        Text("\(index + 1)")
            .font(.caption)
            .bold()
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .stroke(set.reps == 0 ? Color.gray : primaryColor,
                            lineWidth: 1.5
                           )
            )
            .padding(.trailing)
            .foregroundColor(set.reps == 0 ? Color.gray : primaryColor)
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
                    let formatted = String(format: "%.0f", set.weight)
                    return formatted == "0" ? "" : formatted
                },
                set: { newValue in
                    if newValue.isEmpty {
                        set.weight = 0
                        print("update setWeight with an empty value, use 0")
                    } else if let number = Double(newValue) {
                        set.weight = number
                        print("update setWeight with valid value")
                    } else {
                        set.weight = 0
                        print("update setWeight with invalid value, use 0")
                    }
                }
            ))
            .frame(maxWidth: 50, maxHeight: 15)
            .focused($isKeyboardActive)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateSet(set, newWeight: set.weight)
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
                exerciseViewModel.updateSet(set, newReps: set.reps)
            }
        }
        
    }
}
//MARK: Time
extension ExerciseSectionView {
    func setTimeField(for set: Set) -> some View {
        VStack(alignment: .leading) {
            Text("Minutes")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("0", text: Binding(
                get: {
                    let formatted = String(format: "%.0f", set.time)
                    return formatted == "0" ? "" : formatted
                },
                set: { newValue in
                    if newValue.isEmpty {
                        set.time = 0
                        print("update setTime with an empty value, use 0")
                    } else if let number = Double(newValue) {
                        set.time = number
                        print("update setTime with valid value")
                    } else {
                        set.time = 0
                        print("update setTime with invalid value, use 0")
                    }
                }
            ))
            .frame(maxWidth: 50, maxHeight: 15)
            .focused($isKeyboardActive)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateSet(set, newTime: set.time)
            }
        }
        
    }
}
//MARK: Distance
extension ExerciseSectionView {
    func setDistanceField(for set: Set) -> some View {
        VStack(alignment: .leading) {
            Text("Miles")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("0", text: Binding(
                get: {
                    let formatted = String(format: "%.0f", set.time)
                    return formatted == "0" ? "" : formatted
                },
                set: { newValue in
                    if newValue.isEmpty {
                        set.time = 0
                        print("update setDistance with an empty value, use 0")
                    } else if let number = Double(newValue) {
                        set.time = number
                        print("update setDistance with valid value")
                    } else {
                        set.time = 0
                        print("update setDistance with invalid value, use 0")
                    }
                }
            ))
            .frame(maxWidth: 50, maxHeight: 15)
            .focused($isKeyboardActive)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                exerciseViewModel.updateSet(set, newDistance: set.distance)
            }
        }
        
    }
}
//MARK: Notes
extension ExerciseSectionView {
    func setNotesField(for set: Set) -> some View {
        Text("notes")
    }
}


//MARK: Intensity
extension ExerciseSectionView {
    func intensityBar(set:Set) -> some View {
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
    func addButton(primaryColor:Color) -> some View {
        Button {
            exerciseViewModel.addSet(to: exercise, reps: 0, weight: 0, time: 0, distance: 0)
        } label: {
            Text("Add Set")
        }
        .foregroundStyle(primaryColor)
    }
}
