//
//  AddNewWorkoutView.swift
//  RepsX
//
//  Created by Austin Hed on 2/22/25.
//

import SwiftUI

struct EditWorkoutView: View {
    
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
    @FocusState private var startTimeFocused: Bool
    @FocusState private var endTimeFocused: Bool
    
    //time picker
    @State private var isTimePickerPresented: Bool = false
    @State private var editingTime: TimePickerMode = .start
    
    //rating picker
    @State private var isRatingPickerPresented: Bool = false
    
    //Reorder
    @State private var isReordering: Bool = false
    
    //Exercise category & exercise
    @State private var isSelectingExercise: Bool = false
    
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
                
                //Rating row
                ratingRow
                
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
        //MARK: Toolbar & Nav Title
        .toolbar {
            ToolbarItem(placement:.topBarTrailing) {
                Button("Reorder") {
                    isReordering.toggle()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(workoutViewModel.toolbarDate(workout.startTime))
        
        //MARK: Sheets
        .sheet(isPresented: $isTimePickerPresented) {
            if editingTime == .start {
                TimePickerSheet(workout: workout, workoutViewModel: workoutViewModel, mode: .start)
            } else {
                TimePickerSheet(workout: workout, workoutViewModel: workoutViewModel, mode: .end)
            }
        }
        .sheet(isPresented: $isRatingPickerPresented) {
            WorkoutRatingSheet(workout: workout, workoutViewModel: workoutViewModel)
        }
        .sheet(isPresented: $isReordering) {
            ReorderExercisesView(workoutViewModel: workoutViewModel, workout: workout)
        }
        //adding a new exercise
        .sheet(isPresented: $isSelectingExercise) {
            NavigationStack{
                SelectCategoryView(
                    isSelectingExercise: $isSelectingExercise,
                    onExerciseSelected: {predefinedExercise in
                        //take the selected exercise and add it to the workout
                        workoutViewModel.addPremadeExercise(to: workout, exercise: predefinedExercise)
                        //dismiss
                        isSelectingExercise = false
                    }
                )
            }
            
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
    }
}
//start time row
extension EditWorkoutView {
    var startTimeRow: some View {
        HStack {
            Text("Start Time")
            Spacer()
            Button {
                //action
                editingTime = .start
                isTimePickerPresented.toggle()
            } label: {
                Text("\(workoutViewModel.formattedDate(workout.startTime))")
            }
        }
    }
}
//end time row
extension EditWorkoutView {
    var endTimeRow: some View {
        HStack{
            Text("End Time")
            Spacer()
            Button {
                //action
                editingTime = .end
                isTimePickerPresented.toggle()
            } label: {
                if workout.endTime != nil {
                    Text("\(workoutViewModel.formattedDate(workout.endTime!))")
                } else {
                    Text("-")
                }
            }
            
            
        }
    }
}
//rating row
extension EditWorkoutView {
    var ratingRow: some View {
        HStack{
            Text("Rating")
            Spacer()
            Button {
                isRatingPickerPresented.toggle()
            } label: {
                Text(workout.rating.map(String.init) ?? "-")
            }
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
            Button {
                //action
                //menu with two options
                //delete
                //reorder exercises
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}


//MARK: Add Exercise Button
extension EditWorkoutView{
    func addButton(workoutViewModel:WorkoutViewModel) -> some View {
        Button {
            //workoutViewModel.addExercise(to: workout)
            isSelectingExercise.toggle()
            print("add exercise button")
        } label: {
            Text("Add Exercise")
        }
    }
}


//MARK: Date and Time
//time picker enum
enum TimePickerMode {
    case start, end
}
//dateTime picker
struct TimePickerSheet: View {
    var workout:Workout //the workout to edit
    let workoutViewModel: WorkoutViewModel //the viewModel to use
    var mode: TimePickerMode //determine start or end time
    
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
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        switch mode {
                        case .start:
                            workoutViewModel.updateStartTime(workout, tempDate)
                        case .end:
                            workoutViewModel.updateEndTime(workout, tempDate)
                        }
                        dismiss()
                    }
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


//MARK: Rating
//workoutRating picker
struct WorkoutRatingSheet: View {
    var workout: Workout
    let workoutViewModel: WorkoutViewModel
    
    @Environment(\.dismiss) private var dismiss //dismiss
    @State private var tempRating:Int = 5
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Rating", selection: $tempRating) {
                    //nil, disguised as a 0
                    Text("NA").tag(0)
                    //options 1 through 5
                    ForEach(1...5, id: \.self) { rating in
                        Text("\(rating)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationTitle("Rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        //action to update the ratings value
                        workoutViewModel.updateRating(workout, tempRating)
                        print("updated rating")
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
        .onAppear{
            tempRating = workout.rating ?? 0
        }
    }
    
}


//MARK: Preview
#Preview {
    let testWorkout = Workout(name: "Chest Day", startTime: Date().addingTimeInterval(-3600), endTime: Date(), weight: 150.0, notes: "Good Lift", rating: 5)
    let newWorkout = Workout(id: UUID(), startTime: Date())
    NavigationStack{
        EditWorkoutView(workout: newWorkout)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("X") {
                        //isAddNewWorkoutPresented = false
                    }
                }
            }
            .modelContainer(SampleWorkout.shared.modelContainer)
    }
    
    
    
}
