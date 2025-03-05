//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData

struct LogView: View {
    
    //Fetch all workouts
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    //Fetch favorited routines
    @Query(filter: #Predicate{(routine:Routine) in
        return routine.favorite}, sort: \Routine.name) var favoriteRoutines: [Routine]
    
    //toggle to edit workouts, existing or new
    @State private var editNewWorkout: Bool = false
    @State private var editExistingWorkout: Bool = false
    
    //workout to edit, new or existing
    @State private var selectedWorkout: Workout?
    
    //deleting workout confirmation
    @State private var workoutToDelete: Workout?
    
    //View Model
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //binding cars
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
                            if let selectedWorkout = selectedWorkout {
                                editExistingWorkout.toggle()
                                print("selected workout:")
                                print(selectedWorkout.id)
                            } else {
                                print("workout was nil fuck you")
                            }
                            
                        }
                }
            }
            .contentMargins(.horizontal,0)
            .navigationTitle("Log")
            //MARK: Toolbar
            //add workout button
            .toolbar {
                menuToolbarItem
            }
            //MARK: Full Screen Covers
            //show edit workout views
            .fullScreenCover(isPresented: $editNewWorkout) { newWorkoutEditor }
            .fullScreenCover(isPresented: $editExistingWorkout) { existingWorkoutEditor }
            .fullScreenCover(isPresented: $coordinator.showEditWorkout) { coordinatorWorkoutEditor }
            //MARK: On Appear
            //load default workout tempaltes if needed
            .onAppear{
                initializeDefaultDataIfNeeded(context: modelContext)
            }
            
        }
        //MARK: Alert
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

//MARK: Toolbar contents
extension LogView {
    //TODO: delete this
    private var addWorkoutToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let createdWorkout = workoutViewModel.addWorkout(date: Date())
                    selectedWorkout = createdWorkout
                    editNewWorkout = true
                    print("added workout")
                } label: {
                    Image(systemName: "plus")
                }
                .foregroundStyle(userThemeViewModel.primaryColor)
            }
    }
    
    //add workout menu
    private var menuToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                //net new workout
                Section {
                    Button("New Workout") {
                        let createdWorkout = workoutViewModel.addWorkout(date: Date())
                        selectedWorkout = createdWorkout
                        editNewWorkout = true
                    }
                }
                
                //favorite workouts
                Section("Favorite Routines") {
                    ForEach(favoriteRoutines) { routine in
                        Button(routine.name) {
                            let createdWorkout = workoutViewModel.addWorkoutFromRoutine(routine, date: Date())
                            selectedWorkout = createdWorkout
                            editNewWorkout = true
                            print("added workout from Routine")
                        }
                    }
                }
                
                //cancel button
                Section {
                    Button(role: .destructive) {
                        //no action
                    } label: {
                        Text("Cancel")
                    }
                }
                
            } label: {
                Image(systemName: "plus.circle")
            }
            .foregroundStyle(userThemeViewModel.primaryColor)
        }
    }
}

//MARK: Fullscreen Covers
extension LogView {
    //new workout editor
    private var newWorkoutEditor: some View {
        Group {
            if let workoutToEdit = selectedWorkout {
                NavigationStack {
                    EditWorkoutView(workout: workoutToEdit)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Finish") {
                                    workoutViewModel.updateWorkout(workoutToEdit, newEndTime: Date())
                                    if workoutToEdit.name.isEmpty {
                                        let dateName = String(workoutViewModel.toolbarDate(workoutToEdit.startTime))
                                        workoutViewModel.updateWorkout(workoutToEdit, newName:"Workout on \(dateName)")
                                    }
                                    editNewWorkout = false
                                    selectedWorkout = nil
                                }
                                .foregroundStyle(userThemeViewModel.primaryColor)
                            }
                        }
                }
                .environment(\.modelContext, modelContext)
            }
        }
    }

    //existing workout editor
    private var existingWorkoutEditor: some View {
        Group {
            if let workoutToEdit = selectedWorkout {
                NavigationStack {
                    EditWorkoutView(workout: workoutToEdit)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    if workoutToEdit.name.isEmpty {
                                        workoutViewModel.updateWorkout(workoutToEdit, newName: "Unnamed Workout")
                                    }
                                    editExistingWorkout = false
                                    selectedWorkout = nil
                                }
                                .foregroundStyle(userThemeViewModel.primaryColor)
                            }
                        }
                }
                .environment(\.modelContext, modelContext)
            }
        }
    }

    //workout coordinator
    private var coordinatorWorkoutEditor: some View {
        Group {
            if let workout = coordinator.currentWorkout {
                NavigationStack {
                    EditWorkoutView(workout: workout)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Finish") {
                                    workoutViewModel.updateWorkout(workout, newEndTime: Date())
                                    coordinator.showEditWorkout.toggle()
                                }
                                .foregroundStyle(userThemeViewModel.primaryColor)
                            }
                        }
                }
            }
        }
    }
}

//MARK: Alert
//TODO: Fix this so it can be used
extension LogView {
    func deleteWorkoutAlert(
        workoutToDelete: Binding<Workout?>,
        workoutViewModel: WorkoutViewModel
    ) -> some View {
        self.alert("Delete Workout?",
                   isPresented: Binding<Bool>(
                    get: { workoutToDelete.wrappedValue != nil },
                    set: { newValue in
                        if !newValue {
                            workoutToDelete.wrappedValue = nil
                        }
                    }),
                   presenting: workoutToDelete.wrappedValue,
                   actions: { workout in
                       Button("Delete", role: .destructive) {
                           withAnimation {
                               workoutToDelete.wrappedValue = nil
                               workoutViewModel.deleteWorkout(workout)
                           }
                       }
                       Button("Cancel", role: .cancel) {
                           workoutToDelete.wrappedValue = nil
                       }
                   },
                   message: { workout in
                       Text("Are you sure you want to delete this workout?")
                   })
    }
}

#Preview {
    LogView(selectedTab: .constant(.log))
        .modelContainer(SampleData.shared.modelContainer)
}
