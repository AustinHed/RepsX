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
    
    //View Model
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    // Group workouts by month and year (e.g., "February 2025")
    private var groupedWorkouts: [String: [Workout]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return Dictionary(grouping: workouts) { workout in
            dateFormatter.string(from: workout.startTime)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workouts) { workout in
                    LogViewRow(workout: workout)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(Visibility.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .swipeActions {
                            Button {
                                DispatchQueue.main.async{
                                    workoutViewModel.deleteWorkout(workout)
                                    print("delete workout")
                                }
                                
                            } label: {
                                Image(systemName: "trash.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.red)
                            }
                            .tint(.clear)
                            
                        }
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
            //.environment(\.defaultMinListRowHeight, 0)
            .contentMargins(.horizontal,0)
            .navigationTitle("Log")
            //Add workout plus button
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
                                        editExistingWorkout = false
                                        selectedWorkout = nil
                                    }
                                }
                            }
                    }
                    .environment(\.modelContext, modelContext)
                }
            }
        }
    }
}

//MARK: Workout Rows
extension LogView {
    //date
    private func dateBlock(for workout: Workout) -> some View {
        VStack(alignment: .center) {
            let dayOfWeek = workout.startTime.formatted(.dateTime.weekday(.abbreviated))
            Text(dayOfWeek)
                .font(.headline)
            let day = workout.startTime.formatted(.dateTime.day())
            Text(day)
                .font(.subheadline)
                .bold()
        }
        .frame(width: 40, height: 50)
        .padding(1)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(6)
    }
    //details
    private func workoutDetails(for workout: Workout) -> some View {
        VStack(alignment: .leading) {
            //headline and date
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                if let endTime = workout.endTime {
                    let duration = workout.workoutLength
                    Text("\(Int(duration/60)) min")
                        .font(.subheadline)
                } else {
                    Text("-")
                        .font(.subheadline)
                }
            }
            //reps and sets
            ForEach(workout.exercises, id: \.id) { exercise in
                HStack {
                    Text("\(exercise.sets.count) x")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(exercise.name)
                        .font(.subheadline)
                }
            }
        }
    }
    //date + details
    private func logViewRow(for workout: Workout) -> some View {
        HStack(alignment: .top) {
            // Date block (day-of-week and day)
            dateBlock(for: workout)
            
            // Workout details (name, duration, and exercise summary)
            workoutDetails(for: workout)
        }
        .padding(.vertical)
        .padding(.leading, 10)
        .padding(.trailing, 20)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    LogView()
        .modelContainer(SampleData.shared.modelContainer)
}
