//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData

struct LogView: View {
    
    //Fetch workouts
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    // New state variables to manage the new workout and full screen cover
    @State private var editNewWorkout: Bool = false
    @State private var editExistingWorkout: Bool = false
    
    //the workout that should be edited, either as a new or existing workout
    @State private var selectedWorkout: Workout?
    
    //deleting a workout confirmation
    @State private var workoutToDelete: Workout?
    
    //View Model
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    @Binding var selectedTab: ContentView.Tab
    @State var coordinator = WorkoutCoordinator.shared
    
    // Group workouts by month and year (e.g., "February 2025")
    private var groupedWorkouts: [String: [Workout]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return Dictionary(grouping: workouts) { workout in
            dateFormatter.string(from: workout.startTime)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                //TODO: Add section for favorite routines, sliding cards
                //MARK: List
                ForEach(workouts) { workout in
                    LogViewRow(workout: workout)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(Visibility.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    //swipe to delete
                        .swipeActions {
                            Button() {
                                // Instead of deleting immediately, store the workout in a state variable
                                workoutToDelete = workout
                            } label: {
                                Image(systemName: "trash.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.red)
                            }
                            .tint(.clear)
                        }
                    //open workout editor view
                        .onTapGesture {
                            print("tap workout row")
                            //first, clear selected workout
                            selectedWorkout = nil
                            //then, update selected workout with the tapped workout
                            selectedWorkout = workout
                            //then, toggle editExistingWorkout
                            editExistingWorkout.toggle()
                        }
                }
            }
            .contentMargins(.horizontal,0)
            .navigationTitle("Log")
            //Add workout plus button
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Create a new workout
                        let createdWorkout = workoutViewModel.addWorkout(date: Date())
                        selectedWorkout = createdWorkout
                        //toggle the EditWorkoutView
                        editNewWorkout = true
                        print("added workout")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            //MARK: Add & Edit Workouts
            //Edit NEW workout sheet
            .fullScreenCover(isPresented: $editNewWorkout) {
                // Ensure newWorkout is non-nil before presenting the view.
                if let workoutToEdit = selectedWorkout {
                    NavigationStack {
                        EditWorkoutView(workout: workoutToEdit)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Finish") {
                                        //update the end time
                                        workoutViewModel.updateEndTime(workoutToEdit,Date())
                                        //update un-named workouts
                                        if workoutToEdit.name == "" {
                                            let dateName = String(workoutViewModel.toolbarDate(workoutToEdit.startTime))
                                            workoutViewModel.updateName(workoutToEdit, "Workout on \(dateName)")
                                        }
                                        //dismiss the Sheet
                                        editNewWorkout = false
                                        //clear selectedWorkout for re-use
                                        selectedWorkout = nil
                                    }
                                }
                            }
                    }
                    .environment(\.modelContext, modelContext)
                }
            }
            //Edit EXISTING workout sheet
            .fullScreenCover(isPresented: $editExistingWorkout) {
                if let workoutToEdit = selectedWorkout {
                    NavigationStack {
                        EditWorkoutView(workout: workoutToEdit)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Close") {
                                        if workoutToEdit.name == "" {
                                            workoutViewModel.updateName(workoutToEdit, "Unnamed Workout")
                                        }
                                        editExistingWorkout = false
                                        selectedWorkout = nil
                                    }
                                }
                            }
                    }
                    .environment(\.modelContext, modelContext)
                }
            }
            //load default workouts
            .onAppear{
                initializeDefaultDataIfNeeded(context: modelContext)
            }
            .fullScreenCover(isPresented: $coordinator.showEditWorkout) {
                if let workout = coordinator.currentWorkout {
                    NavigationStack{
                        EditWorkoutView(workout: workout)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Finish") {
                                        //update the end time
                                        workoutViewModel.updateEndTime(workout,Date())
                                        //dismiss the Sheet
                                        coordinator.showEditWorkout.toggle()
                                    }
                                }
                            }
                    }
                }
            }
            
        }
        //delete workout confirmation
        .alert("Delete Workout?", isPresented: Binding<Bool>(
            get: { workoutToDelete != nil },
            set: { newValue in
                if !newValue { workoutToDelete = nil }
            }
        ), presenting: workoutToDelete) { workout in
            Button("Delete", role: .destructive) {
                withAnimation {
                    workoutToDelete = nil
                    workoutViewModel.deleteWorkout(workout)
                }
            }
            Button("Cancel", role: .cancel) {
                workoutToDelete = nil
            }
        } message: { workout in
            Text("Are you sure you want to delete this workout?")
        }
        
    }
}

#Preview {
    LogView(selectedTab: .constant(.log))
        .modelContainer(SampleData.shared.modelContainer)
}
