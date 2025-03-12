//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData
import SwipeActions

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
            
            ScrollView{
                LazyVStack(spacing: 12) {
                    ForEach(workouts) { workout in
                        //logViewRow
                        SwipeView{
                            LogViewRow(workout: workout)
                                .onTapGesture {
                                    selectedWorkout = workout
                                }
                        }
                        //swipe actions
                        trailingActions: { _ in
                            SwipeAction(
                                systemImage: "trash",
                                backgroundColor: .red
                            ){
                                workoutToDelete = workout
                            }
                            .foregroundStyle(.white)

                        }
                        .swipeMinimumDistance(25)
                        .swipeActionCornerRadius(16)
                        .padding(.horizontal, 16)
                        
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .animation(.easeInOut(duration: 0.3), value: workouts)
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
            .fullScreenCover(item: $selectedWorkout) { workout in
                existingWorkoutEditor(for: workout)
                    .environment(\.modelContext, modelContext)
            }
            .fullScreenCover(isPresented: $coordinator.showEditWorkout) { coordinatorWorkoutEditor }
            //MARK: On Appear
            .onAppear{
                //load default workout tempaltes if needed
                initializeDefaultDataIfNeeded(context: modelContext)
                initializeWorkoutsIfNeeded(context: modelContext)
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
    private func existingWorkoutEditor(for workout: Workout) -> some View {
        NavigationStack {
            EditWorkoutView(workout: workout)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            // Final updates before dismissing
                            if workout.name.isEmpty {
                                workoutViewModel.updateWorkout(workout, newName: "Unnamed Workout")
                            }
                            selectedWorkout = nil
                        }
                        .foregroundStyle(userThemeViewModel.primaryColor)
                    }
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

//#Preview {
//    LogView(selectedTab: .constant(.log))
//        .modelContainer(SampleData.shared.modelContainer)
//}
