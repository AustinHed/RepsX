//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData
import SwipeActions


struct WorkoutHistoryView: View {
    
    //Queries
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Query(filter: #Predicate{(routine:Routine) in
        return routine.favorite}, sort: \Routine.name) var favoriteRoutines: [Routine]
    //TODO: pass this array when opening a workout, to be used to access Exercise History when viewing an exercise
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
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
    
    //Tab
    @Binding var selectedTab: ContentView.Tab
    @State var coordinator = WorkoutCoordinator.shared
    
    
    //TODO: fix grouping workouts - breaks when updating intensity, not sure why
    // Group workouts by month and year (e.g., "February 2025")
//    private var groupedWorkouts: [String: [Workout]] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMM yyyy"
//        return Dictionary(grouping: workouts) { workout in
//            dateFormatter.string(from: workout.startTime)
//        }
//    }
    // Sort the keys (months) in descending order (most recent first)
//    private var sortedGroupKeys: [String] {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        return groupedWorkouts.keys.sorted { key1, key2 in
//            guard let date1 = formatter.date(from: key1),
//                  let date2 = formatter.date(from: key2)
//            else { return false }
//            return date1 > date2
//        }
//    }
    
    //MARK: Body
    var body: some View {
        NavigationStack {
            ZStack{
                CustomBackground(themeColor: themeColor)
                ScrollView{
                    LazyVStack(spacing: 12) {
                        
                        // Calendar at the top
                        WorkoutHistoryCalendarView(workouts: workouts)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .padding(.top)
                        if workouts.isEmpty {
                            noWorkouts
                            
                        } else {
                            ForEach(workouts) { workout in
                                //logViewRow
                                SwipeView{
                                    WorkoutHistoryRow(workout: workout)
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
                }
                .animation(.easeInOut(duration: 0.3), value: workouts)
                .contentMargins(.horizontal,0)
                .navigationTitle("History")
            }
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
            .safeAreaInset(edge: .bottom) {
                // Add extra space (e.g., 100 points)
                Color.clear.frame(height: 70)
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

//MARK: No Workouts State
extension WorkoutHistoryView {
    private var noWorkouts: some View {
        Button {
            let createdWorkout = workoutViewModel.addWorkout(date: Date())
            selectedWorkout = createdWorkout
            editNewWorkout = true
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.white)
                    .frame(height: 45)
                    .padding(.horizontal)
                
                Text("Add your first workout")
                    .foregroundStyle(themeColor)
            }
        }
    }
}
//MARK: Toolbar contents
extension WorkoutHistoryView {
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
            .foregroundStyle(themeColor)
        }
    }
}

//MARK: Fullscreen Covers
extension WorkoutHistoryView {
    //new workout editor
    //TODO: need to pass all workouts here
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
                                .foregroundStyle(themeColor)
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
                        .foregroundStyle(themeColor)
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
                                .foregroundStyle(themeColor)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    WorkoutHistoryView(selectedTab: .constant(.history))
}
