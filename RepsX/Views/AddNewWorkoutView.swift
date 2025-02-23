//
//  AddNewWorkoutView.swift
//  RepsX
//
//  Created by Austin Hed on 2/22/25.
//

import SwiftUI

struct AddNewWorkoutView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //the initialized workout
    @State var workout: Workout
    
    //viewModel
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    // Focus state to detect when the name field loses focus
    @FocusState private var nameFieldFocused: Bool
    
    
    var body: some View {
        List {
            //MARK: Workout Details
            Section() {
                //Name row with inline editing.
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: Binding(
                        get: { workout.name },
                        set: { workout.name = $0 }
                    ))
                    .multilineTextAlignment(.trailing)
                    // If the workout name is blank, the text appears in light gray (via the placeholder), otherwise in black.
                    .foregroundColor(workout.name.isEmpty ? .gray : .black)
                    .focused($nameFieldFocused)
                    .onSubmit {
                        // Called when the user taps Return
                        workoutViewModel.updateName(workout, workout.name)
                        print("updated name returned, workoutName \(workout.name)")
                    }
                    .onChange(of: nameFieldFocused) { isFocused in
                        // When focus is lost, update the workout name.
                        if !isFocused {
                            workoutViewModel.updateName(workout, workout.name)
                            print("updated name not focused, workoutName \(workout.name)")
                            
                        }
                    }
                }
                
                //Start time row
                HStack {
                    Text("Start Time")
                    Spacer()
                    //maybe this should be a button that can trigger the time changer?
                    Text("\(workoutViewModel.formattedDate(workout.startTime))")
                }
                
                HStack{
                    Text("End Time")
                    Spacer()
                    if workout.endTime != nil {
                        Text("\(workoutViewModel.formattedDate(workout.endTime!))")
                    } else {
                        Text("-")
                    }
                }
                
                HStack{
                    Text("Notes")
                    Spacer()
                    Text("\(workout.notes ?? "-")")
                }
                
            }
            
            //MARK: Exercises
            ForEach(workout.exercises) {exercise in
                Text("Cat")
                //one row for the workout name
                //for each, with each row being a set
                //one row with an add set
            }
            
            //MARK: Add Exercise Button
            Section() {
                Button {
                    //action
                    print("add exercisee button")
                } label: {
                    Text("Add Exercise")
                }
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement:.topBarLeading) {
                Text("finish button")
            }
            ToolbarItem(placement:.topBarTrailing) {
                Text("more button")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(workoutViewModel.toolbarDate(workout.startTime))
        
    }
}

#Preview {
    let testWorkout = Workout(name: "Chest Day", startTime: Date().addingTimeInterval(-3600), endTime: Date(), weight: 150.0, notes: "Good Lift", rating: 5)
    let newWorkout = Workout(id: UUID(), startTime: Date())
    NavigationStack{
        AddNewWorkoutView(workout: newWorkout)
    }
    
    
}
