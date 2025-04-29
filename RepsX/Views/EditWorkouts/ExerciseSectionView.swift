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
    var exercise: Exercise
    
    //most recent exercise
    ///the previous sets from when a user performed this exercise. Used to show past weight lifted
    @State private var previousSets: [Set] = []
    @State private var didLoadPreviousSets: Bool = false
    
    //viewModel
    private var exerciseViewModel: ExerciseViewModel {
        ExerciseViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //focus states
    @FocusState var isKeyboardActive: Bool //to dismiss the keyboard
    @FocusState private var setWeightFocused: Bool
    @FocusState private var setRepsFocused: Bool
    @FocusState private var setTimeFocused: Bool
    @FocusState private var setDistanceFocused: Bool
    
    //body
    var body: some View {
        //sets
        ForEach(Array(exercise.sets.sorted { $0.order < $1.order }.enumerated()), id: \.element.id) { index, set in
            ///display sets in order of set.order
            HStack  {
                //number
                exerciseNumberField(index: index, set: set, primaryColor: primaryColor)
                
                //values to display, based on modality
                ///ex. weight x reps, distance x time
                if set.exercise?.modality == .repetition {
                    setWeightField(for: set)
                    setRepsField(for: set)
                } else if set.exercise?.modality == .endurance {
                    setDistanceField(for: set)
                    setTimeField(for: set)
                } else {
                    setNotesField(for: set)
                }
                
                //Intensity
                intensityBar(set:set)
                
            }
            .onAppear {
                if !didLoadPreviousSets{
                    print("loading previous sets")
                    previousSets = exerciseViewModel.fetchMostRecentWorkout(for: exercise.templateId)
                    didLoadPreviousSets = true
                }
                    
                
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
        addButton(primaryColor: primaryColor)
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
/// A custom text field for weight input that decouples the visual text from the underlying model value
/// and updates the model when focus is lost or when the user submits.
struct WeightTextField: View {
    @Binding var weight: Double
    let placeholder: String

    // Local state for the text field input.
    @State private var weightText: String = ""
    // Focus state for detecting when the field gains/loses focus.
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Lbs")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("", text: $weightText, prompt: Text(placeholder))
                .frame(maxWidth: 50, maxHeight: 15)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .submitLabel(.done)
                // On first appearance, initialize the text field.
                .onAppear {
                    // If weight is 0, show an empty text field to display the placeholder.
                    if weight == 0 {
                        weightText = ""
                    } else {
                        weightText = (weight.truncatingRemainder(dividingBy: 1) == 0) ?
                            String(format: "%.0f", weight) :
                            String(format: "%.1f", weight)
                    }
                }
                // As the user types, try to update the model if the text can be converted.
                .onChange(of: weightText) { newValue in
                    if let newWeight = Double(newValue) {
                        weight = newWeight
                    }
                }
                // When the user submits (e.g. taps "Done"), ensure the model is updated.
                .onSubmit {
                    if let newWeight = Double(weightText) {
                        weight = newWeight
                    }
                }
                // When the field loses focus, update the underlying model.
                .onChange(of: isFocused) { focused in
                    if !focused {
                        if let newWeight = Double(weightText) {
                            weight = newWeight
                        }
                    }
                }
        }
    }
}
extension ExerciseSectionView {
    /// Returns an editable weight field view for a given set.
    func setWeightField(for set: Set) -> some View {
        // Compute the placeholder: use a historical set's value if available, otherwise "0".
        let placeholder: String = {
            if let historicalSet = previousSets.first(where: { $0.order == set.order && $0.weight != 0 }) {
                return (historicalSet.weight.truncatingRemainder(dividingBy: 1) == 0) ?
                    String(format: "%.0f", historicalSet.weight) :
                    String(format: "%.1f", historicalSet.weight)
            }
            return "0"
        }()
        
        // Use our custom WeightTextField.
        return WeightTextField(weight: Binding(
            get: { set.weight },
            set: { newValue in set.weight = newValue }
        ), placeholder: placeholder)
    }
}

//MARK: Reps
struct RepsTextField: View {
    @Binding var reps: Int
    let placeholder: String

    // Local state for the text field input.
    @State private var repsText: String = ""
    // Focus state for detecting when the field gains/loses focus.
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Reps")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("", text: $repsText, prompt: Text(placeholder))
                .frame(maxWidth: 50, maxHeight: 15)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .submitLabel(.done)
                // On first appearance, initialize the text field.
                .onAppear {
                    // If reps is 0, leave the field empty so that the placeholder is visible.
                    if reps == 0 {
                        repsText = ""
                    } else {
                        repsText = String(format: "%d", reps)
                    }
                }
                // As the user types, update the model if the text converts to an Int.
                .onChange(of: repsText) { newValue in
                    if let newReps = Int(newValue) {
                        reps = newReps
                    }
                }
                // When the user submits (e.g. taps "Done"), update the model.
                .onSubmit {
                    if let newReps = Int(repsText) {
                        reps = newReps
                    }
                }
                // When the field loses focus, update the underlying model.
                .onChange(of: isFocused) { focused in
                    if !focused {
                        if let newReps = Int(repsText) {
                            reps = newReps
                        }
                    }
                }
        }
    }
}
extension ExerciseSectionView {
    func setRepsField(for set: Set) -> some View {
        let placeholder: String = {
            if let historicalSet = previousSets.first(where: { $0.order == set.order && $0.reps != 0 }) {
                return String(format: "%d", historicalSet.reps)
            }
            return "0"
        }()
        
        return RepsTextField(reps: Binding(
            get: { set.reps },
            set: { newValue in set.reps = newValue }
        ), placeholder: placeholder)
    }
}

//MARK: Time
struct TimeTextField: View {
    @Binding var time: Double
    let placeholder: String

    // Local state for the text field input.
    @State private var timeText: String = ""
    // Focus state for detecting when the field gains/loses focus.
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Minutes")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("", text: $timeText, prompt: Text(placeholder))
                .frame(maxWidth: 50, maxHeight: 15)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .submitLabel(.done)
                .onAppear {
                    // If time is 0, leave the field empty to show the placeholder.
                    if time == 0 {
                        timeText = ""
                    } else {
                        timeText = String(format: "%.1f", time)
                    }
                }
                .onChange(of: timeText) { newValue in
                    if let newTime = Double(newValue) {
                        time = newTime
                    }
                }
                .onSubmit {
                    if let newTime = Double(timeText) {
                        time = newTime
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        if let newTime = Double(timeText) {
                            time = newTime
                        }
                    }
                }
        }
    }
}
extension ExerciseSectionView {
    func setTimeField(for set: Set) -> some View {
            let placeholder: String = {
                if let historicalSet = previousSets.first(where: { $0.order == set.order && $0.time != 0 }) {
                    return String(format: "%.1f", historicalSet.time)
                }
                return "0"
            }()
            
            return TimeTextField(time: Binding(
                get: { set.time },
                set: { newValue in set.time = newValue }
            ), placeholder: placeholder)
        }
}
//MARK: Distance
struct DistanceTextField: View {
    @Binding var distance: Double
    let placeholder: String

    // Local state for the text field input.
    @State private var distanceText: String = ""
    // Focus state for detecting when the field gains/loses focus.
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Miles")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("", text: $distanceText, prompt: Text(placeholder))
                .frame(maxWidth: 50, maxHeight: 15)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .submitLabel(.done)
                .onAppear {
                    // If distance is 0, leave the field empty to display the placeholder.
                    if distance == 0 {
                        distanceText = ""
                    } else {
                        distanceText = String(format: "%.1f", distance)
                    }
                }
                .onChange(of: distanceText) { newValue in
                    if let newDistance = Double(newValue) {
                        distance = newDistance
                    }
                }
                .onSubmit {
                    if let newDistance = Double(distanceText) {
                        distance = newDistance
                    }
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        if let newDistance = Double(distanceText) {
                            distance = newDistance
                        }
                    }
                }
        }
    }
}
extension ExerciseSectionView {
    func setDistanceField(for set: Set) -> some View {
            let placeholder: String = {
                if let historicalSet = previousSets.first(where: { $0.order == set.order && $0.distance != 0 }) {
                    return String(format: "%.1f", historicalSet.distance)
                }
                return "0"
            }()
            
            return DistanceTextField(distance: Binding(
                get: { set.distance },
                set: { newValue in set.distance = newValue }
            ), placeholder: placeholder)
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
//MARK: Notes
extension ExerciseSectionView {
    func setNotesField(for set: Set) -> some View {
        Text("notes")
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



