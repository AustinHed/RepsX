//
//  AddNewWorkoutView.swift
//  RepsX
//
//  Created by Austin Hed on 2/22/25.
//

import SwiftUI

struct EditWorkoutView: View {
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    //the initialized workout
    @State var workout: Workout
    
    @State var exerciseToReplace: Exercise?
    
    //viewModel
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    // Focus state to detect when the name field loses focus
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var startTimeFocused: Bool
    @FocusState private var endTimeFocused: Bool
    
    //time picker
    @State private var activeTimePicker: TimePickerMode? = nil
    
    //Reorder
    @State private var isReordering: Bool = false
    
    //add new exercise
    @State private var isSelectingExercise: Bool = false
    
    //replace existing exercise
    @State private var isReplacingExercise: Bool = false
    
    //delete confirmation
    @State private var showDeleteConfirmation = false
    
    //show timer
    @State private var showTimer:Bool = false
    
    var body: some View {
        
        List {
            //MARK: Workout Details
            Section() {
                //Name row with inline editing.
                nameEditingRow
                
                //Start time row
                startTimeRow
                
                //End time row
                endTimeRow
                
                //TODO: Rate the workout 1 - 5 stars
                
            }
            
            //MARK: Exercises
            ForEach(workout.exercises.sorted {$0.order < $1.order}) { exercise in
                Section() {
                    //name
                    exerciseName(exercise)
                    //delete exercise
                        .swipeActions {
                            Button("delete", role: .destructive) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    withAnimation{
                                        workoutViewModel.deleteExercise(exercise, from: workout)
                                    }
                                }
                            }
                        }
                    
                    //sets
                    ExerciseSectionView(exercise: exercise)
                    
                }
            }
            
            //MARK: Add Exercise Button
            Section() {
                addButton(workoutViewModel: workoutViewModel)
            }
            
            
        }
        .tint(themeColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(workoutViewModel.toolbarDate(workout.startTime))
        //MARK: Toolbar
        .toolbar {
            
            //Timer
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut){
                        showTimer.toggle()
                    }
                    
                } label: {
                    Image(systemName: "timer")
                }
                .foregroundStyle(themeColor)
                
            }
            //Reorder & Delete
            ToolbarItem(placement:.topBarTrailing) {
                Menu {
                    Button {
                        isReordering.toggle()
                    } label: {
                        HStack{
                            Text("Reorder")
                            Spacer()
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation.toggle()
                    } label: {
                        HStack{
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    
                } label: {
                    Image(systemName:"ellipsis.circle")
                }
                .foregroundStyle(themeColor)
                .confirmationDialog("Are you sure you want to delete this Workout", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        workoutViewModel.deleteWorkout(workout)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                
            }
            
        }
        //MARK: Sheets
        //Time picker
        .sheet(item: $activeTimePicker) { mode in
            TimePickerSheet(
                workout: workout,
                workoutViewModel: workoutViewModel,
                mode: mode,
                primaryColor: themeColor
            )
        }
        //Reorder / Delete
        .sheet(isPresented: $isReordering) {
            ReorderExercisesView(workoutViewModel: workoutViewModel, workout: workout, primaryColor: themeColor)
        }
        //add new exercise
        .sheet(isPresented: $isSelectingExercise) {
            NavigationStack{
                SelectCategoryView(
                    isSelectingExercise: $isSelectingExercise,
                    onExerciseSelected: {exerciseTemplate in
                        //take the selected exercise and add it to the workout
                        workoutViewModel.addPremadeExercise(to: workout, exercise: exerciseTemplate)
                        //dismiss
                        isSelectingExercise = false
                    }
                )
            }
            .tint(themeColor)
            
        }
        //swap existing exercise
        .sheet(isPresented: $isReplacingExercise){
            NavigationStack{
                SelectCategoryView(
                    isSelectingExercise: $isReplacingExercise,
                    onExerciseSelected: {exerciseTemplate in
                        if exerciseToReplace != nil{
                            workoutViewModel.replaceExercise(in: workout, exerciseToRemove: exerciseToReplace!, exerciseToAdd: exerciseTemplate)
                            isReplacingExercise = false
                        } else {
                            print("can't find the exercise to replace")
                        }
                        
                    }
                )
            }
        }
        .sheet(isPresented: $isReplacingExercise, content: {
            SelectCategoryView(
                isSelectingExercise: $isReplacingExercise,
                onExerciseSelected: {exerciseTemplate in
                    
                }
            )
        })
        //Timer
        .sheet(isPresented: $showTimer) {
            Spacer()
            ExerciseTimer(primaryColor:themeColor)
                .padding(.bottom, 10)
                .presentationDetents([.height(70)])
                .presentationBackgroundInteraction(.enabled)
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 50)
        }
    }
    
}


//MARK: Workout Details
//Name Row
extension EditWorkoutView {
    var nameEditingRow: some View {
        HStack {
            Text("Name")
            Spacer()
            TextField("Unnamed Workout", text: Binding(
                get: { workout.name },
                //set: { workout.name = $0 }
                set: { newName in
                    if newName == "" {
                        workout.name = ""
                    } else {
                        workout.name = newName
                    }
                }
            ))
            .multilineTextAlignment(.trailing)
            // If the workout name is blank, the text appears in light gray (via the placeholder), otherwise in black.
            .foregroundColor(workout.name.isEmpty ? .gray : .black)
            .focused($nameFieldFocused)
            .onSubmit {
                // Called when the user taps Return
                workoutViewModel.updateWorkout(workout, newName: workout.name)
            }
            .onChange(of: nameFieldFocused) {
                if !nameFieldFocused {
                    workoutViewModel.updateWorkout(workout, newName: workout.name)
                }
            }
        }
    }
}
//start time row
extension EditWorkoutView {
    // Start time row:
    var startTimeRow: some View {
        HStack {
            Text("Start Time")
            Spacer()
            Button {
                activeTimePicker = .start
            } label: {
                Text("\(workoutViewModel.formattedDate(workout.startTime))")
            }
            .foregroundStyle(themeColor)
        }
    }
}
//end time row
extension EditWorkoutView {
    // End time row:
    var endTimeRow: some View {
        HStack {
            Text("End Time")
            Spacer()
            Button {
                activeTimePicker = .end
            } label: {
                if let endTime = workout.endTime {
                    Text("\(workoutViewModel.formattedDate(endTime))")
                } else {
                    Text("-")
                }
            }
            .foregroundStyle(themeColor)
        }
    }
}

//MARK: Exercises
//exercise name
extension EditWorkoutView {
    func exerciseName(_ exercise: Exercise) -> some View {
        HStack {
            Text(exercise.name)
                .font(.headline)
            
            Spacer()
            Menu {
                //replace
                Button {
                    exerciseToReplace = exercise
                    isReplacingExercise.toggle()
                } label: {
                    HStack{
                        Text("Replace")
                        Spacer()
                        Image(systemName: "rectangle.2.swap")
                    }
                }
                //reorder
                Button {
                    isReordering.toggle()
                } label: {
                    HStack{
                        Text("Reorder")
                        Spacer()
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                //delete
                Button(role:.destructive) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        withAnimation{
                            workoutViewModel.deleteExercise(exercise, from: workout)
                        }
                    }
                } label: {
                    HStack{
                        Text("Delete")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .foregroundStyle(themeColor)
        }
    }
}
//MARK: Add Exercise Button
extension EditWorkoutView{
    func addButton(workoutViewModel:WorkoutViewModel) -> some View {
        Button {
            isSelectingExercise.toggle()
        } label: {
            Text("Add Exercise")
        }
        .foregroundStyle(themeColor)
    }
}

//MARK: Date and Time
//time picker enum
enum TimePickerMode: Int, Identifiable {
    case start, end
    var id: Int { self.rawValue }
}
//dateTime picker
struct TimePickerSheet: View {
    var workout:Workout //the workout to edit
    let workoutViewModel: WorkoutViewModel //the viewModel to use
    var mode: TimePickerMode //determine start or end time
    let primaryColor:Color
    
    @Environment(\.dismiss) private var dismiss //dismiss
    @State private var tempDate: Date = Date() //value to play with
    
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $tempDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .navigationTitle(mode == . start ? "Edit Start Time" : "Edit End Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(primaryColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        switch mode {
                        case .start:
                            workoutViewModel.updateWorkout(workout, newStartTime: tempDate)
                        case .end:
                            workoutViewModel.updateWorkout(workout, newEndTime: tempDate)
                        }
                        dismiss()
                    }
                    .foregroundStyle(primaryColor)
                }
            }
        }
        .onAppear {
            switch mode {
            case .start:
                tempDate = workout.startTime
            case .end:
                tempDate = workout.endTime ?? Date()
            }
        }
        .presentationDetents([.fraction(0.5)])
    }
}

