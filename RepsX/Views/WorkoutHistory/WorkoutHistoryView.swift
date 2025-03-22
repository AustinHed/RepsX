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
    
    
    
    //MARK: - tab
    //binding vars
    @Binding var selectedTab: MainTabbedView.TabOptions
    @State var coordinator = WorkoutCoordinator.shared
    
    // Group workouts by month and year (e.g., "February 2025")
    //TODO: fix grouping workouts - breaks when updating intensity, not sure why
    private var groupedWorkouts: [String: [Workout]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return Dictionary(grouping: workouts) { workout in
            dateFormatter.string(from: workout.startTime)
        }
    }
    // Sort the keys (months) in descending order (most recent first)
    private var sortedGroupKeys: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return groupedWorkouts.keys.sorted { key1, key2 in
            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2)
            else { return false }
            return date1 > date2
        }
    }
    
    //MARK: Body
    var body: some View {
        NavigationStack {
            ZStack{
                themeColor.opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                WavyBackground(startPoint: 50,
                               endPoint: 120,
                               point1x: 0.6,
                               point1y: 0.1,
                               point2x: 0.4,
                               point2y: 0.015,
                               color: themeColor.opacity(0.2)
                )
                    .edgesIgnoringSafeArea(.all)
                WavyBackground(startPoint: 120,
                               endPoint: 50,
                               point1x: 0.4,
                               point1y: 0.01,
                               point2x: 0.6,
                               point2y: 0.25,
                               color: themeColor.opacity(0.2)
                )
                    .edgesIgnoringSafeArea(.all)
                ScrollView{
                    LazyVStack(spacing: 12) {
                        
                        // Calendar at the top
                        WorkoutHistoryCalendarView(workouts: workouts)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .padding(.top)
                        
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
                //.background(Color(UIColor.systemGroupedBackground))
                //.background(themeColor.opacity(0.1))
                //.background(WavyBackground())
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
            .onAppear{
                //load default workout tempaltes if needed
                initializeDefaultDataIfNeeded(context: modelContext)
                initializeWorkoutsIfNeeded(context: modelContext)
            }
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

//MARK: Alert
//TODO: Fix this so it can be used
extension WorkoutHistoryView {
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

//MARK: Calendar section
extension WorkoutHistoryView {
    // Generate 14 dates starting from 13 days ago through today.
    private var fourteenDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Create an array of 14 dates, where the first element is 13 days ago and the last is today.
        return (0..<14).compactMap { offset in
            calendar.date(byAdding: .day, value: -(13 - offset), to: today)
        }
    }
    
    // Split the dates into two rows.
    private var firstRow: [Date] {
        Array(fourteenDays.prefix(7))
    }
    
    private var secondRow: [Date] {
        Array(fourteenDays.suffix(7))
    }
    
    // Formatter for the date in "dd/MM" format.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    private func calendar(firstRow: [Date], secondRow:[Date]) -> some View {
        VStack(spacing: 16) {
            // First row of circles.
            HStack(spacing: 16) {
                ForEach(firstRow, id: \.self) { date in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Text(formattedDate(date))
                                .font(.caption)
                                .foregroundColor(.black)
                        )
                }
            }
            // Second row of circles.
            HStack(spacing: 16) {
                ForEach(secondRow, id: \.self) { date in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text(formattedDate(date))
                                .font(.caption)
                                .foregroundColor(.black)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        
    }
    
    
}
