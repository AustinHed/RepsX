//
//  NewConsistencyGoalView.swift
//  RepsX
//
//  Created by Austin Hed on 4/11/25.
//

import SwiftUI
import SwiftData
import Foundation

enum GoalType: String, CaseIterable, Codable {
    case recurring = "Recurring"
    case target = "Target"
}

struct NewGoalView: View {
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    //view models
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    private var targetGoalViewModel: TargetGoalViewModel{
        TargetGoalViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //the new goal properties
    @State var type: GoalType = .target
    @State var name: String = ""
    @State var relatedExerciseId: UUID? = nil
    @State var relatedExerciseName: String? = nil
    @State var startDate: Date = Date()
    
    //recurring goal properties
    @State var measurement: GoalMeasurement = .reps
    @State var timeframe: GoalTimeframe = .weekly
    @State var target: Double = 0.0
    
    //target goal properties
    @State var targetType: TargetGoalType = .strength
    @State var primaryValue: Double = 0
    @State var secondaryValue: Double = 0
    
    //toggles
    @State var showDatePicker: Bool = false
    @State var showExercisePicker: Bool = false
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading, spacing: 12){
                //Name entry
                nameEntry
                
                //goalType
                goalType
                
                //Details
                switch type {
                case .recurring:
                    recurringDetails
                case .target:
                    targetDetails
                }
                
                //Start date
                startDateSection
                
                //create button
                createGoalButton
                
            }
        }
        .padding(.horizontal)
        .navigationTitle("New Goal")
        //MARK: Sheets
        .sheet(isPresented: $showDatePicker) {
            GoalTimePickerSheet(startDate: $startDate)
        }
        .sheet(isPresented: $showExercisePicker) {
            NavigationStack{
                SelectCategoryView(
                    isSelectingExercise: $showExercisePicker,
                    onExerciseSelected: {exerciseTemplate in
                        //take the selected exercise and fetch the ID
                        relatedExerciseId = exerciseTemplate.id
                        relatedExerciseName = exerciseTemplate.name
                        //dismiss
                        showExercisePicker = false
                    }
                )
            }
            .tint(primaryColor)
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
        .tint(primaryColor)
    }
}
//MARK: Name entry
extension NewGoalView {
    var nameEntry: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            //textEntry
            TextField("Name", text: $name)
                .padding()
        }
    }
}

//MARK: Goal Type
extension NewGoalView {
    var goalType: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            //choose type
            HStack(alignment:.center){
                Text("Type")
                    .font(.headline)
                    .bold()
                    .padding(.leading)
                    .frame(width: 100, alignment:.leading)
                Spacer()
                EnumPicker<GoalType>(selection: $type) { option in
                    "\(option.rawValue)"
                }.padding(.horizontal)
            }
            .padding(.vertical, 6)
        }
    }
}

//MARK: Details
extension NewGoalView {
    var recurringDetails: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            VStack(alignment:.leading){
                //Measure
                HStack (alignment:.center) {
                    Text("Measure")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)

                    EnumPicker<GoalMeasurement>(selection: $measurement){option in
                        "\(option.rawValue)"
                    }.padding(.horizontal)
                }
                .padding(.top,10)
                Divider().padding(.leading)
                
                
                //Interval
                HStack(alignment:.center){
                    Text("Interval")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    
                    EnumPicker<GoalTimeframe>(selection: $timeframe){option in
                        "\(option.rawValue)"
                    }.padding(.horizontal)
                }
                Divider().padding(.leading)
                
                //Optional - exercise
                if measurement == .reps{
                    HStack(alignment: .center){
                        Text("Exercise")
                            .font(.headline)
                            .bold()
                            .padding(.leading)
                            .frame(width: 100, alignment:.leading)
                        Spacer()
                        //pick the exercise
                        Button {
                            showExercisePicker.toggle()
                        } label: {
                            Text(relatedExerciseName != nil ? relatedExerciseName! :"Select Exercise")
                                .padding(.trailing, 25)
                        }

                    }
                    .padding(.top,8)
                    .padding(.bottom, 8)
                    
                    Divider().padding(.leading)
                }
                
                //Target
                HStack (alignment:.bottom){
                    Text("Target")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    
                    //text field
                    TextField("enter target", value: $target, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        
                        
                    //TODO: clean up, is spaced weird
                    //measure
                    switch measurement {
                    case .minutes:
                        Text("mins")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            
                            
                    case .workouts:
                        Text("workouts")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            
                    case .reps:
                        Text("reps")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                        
                    //timeframe
                    switch timeframe {
                    case .daily:
                        Text("every day")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 15)
                    case .weekly:
                        Text("every week")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 15)
                    case .monthly:
                        Text("every month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 15)
                    }
                        
                    
                    Spacer()
                }
                .padding(.bottom)
                .padding(.top,5)
                
            }
            
        }
    }
}

//MARK: Target Goal Properties
extension NewGoalView {
    var targetDetails: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            VStack(alignment:.leading){
                
                //Measure
                HStack(alignment:.center){
                    Text("Measure")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    
                    EnumPicker<TargetGoalType>(selection: $targetType){option in
                        "\(option.rawValue)"
                    }.padding(.horizontal)
                    
                }
                .padding(.top,10)
                Divider().padding(.leading)
                
                //Select Exercise
                HStack(alignment: .center){
                    Text("Exercise")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    Spacer()
                    //pick the exercise
                    Button {
                        showExercisePicker.toggle()
                    } label: {
                        Text(relatedExerciseName != nil ? relatedExerciseName! :"Select Exercise")
                            .padding(.trailing, 25)
                    }

                }
                .padding(.top,8)
                .padding(.bottom, 8)
                Divider().padding(.leading)
                
                //Primary value
                HStack (alignment:.bottom){
                    Text(targetType == .strength ? "Weight" : "Distance")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    
                    //text field
                    TextField("enter target", value: $primaryValue, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        
                        
                    //TODO: clean up, is spaced weird
                    //measure
                    switch targetType {
                    case .strength:
                        Text("lbs")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing,30)
                            
                    case .pace:
                        Text("miles")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing,30)
                    }
                        
                    
                }
                .padding(.bottom,10)
                .padding(.top,5)
                Divider().padding(.leading)
                
                //Secondary value
                HStack (alignment:.bottom){
                    Text(targetType == .strength ? "Reps" : "Minutes")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                    
                    //text field
                    TextField("enter target", value: $secondaryValue, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        
                        
                    //TODO: clean up, is spaced weird
                    //measure
                    switch targetType {
                    case .strength:
                        Text("reps")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing,30)
                            
                    case .pace:
                        Text("minutes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.trailing,30)
                    }
                        
                    
                }
                .padding(.bottom)
                .padding(.top,5)
            }
        }
    }
}

//MARK: Start Date
extension NewGoalView {
    var startDateSection: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            HStack{
                Text("Start on")
                    .font(.headline)
                    .bold()
                Spacer()
                Button {
                    showDatePicker.toggle()
                } label: {
                    Text("\(startDate, format: Date.FormatStyle.dateTime.month(.wide).day().year())")
                }
                
            }
            .padding()
        }
    }
}

//MARK: Time picker sheet
struct GoalTimePickerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Binding var startDate: Date
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                DatePicker("", selection: $startDate, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                Spacer()
            }
            .toolbar {
                //TODO: Delete one, they are duplicative
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(primaryColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(primaryColor)
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
    }
}

//MARK: Create button
extension NewGoalView {
    var createGoalButton: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("lightAndDarkBackgrounds"))
            
            Button {
                //TODO: different action based on goalType
                //action
                switch type {
                case .recurring:
                    consistencyGoalViewModel.addGoal(name: name,
                                                     goalTimeframe: timeframe,
                                                     goalMeasurement: measurement,
                                                     goalTarget: target,
                                                     exerciseId: measurement == .reps ? relatedExerciseId : nil,
                                                     startDate: startDate
                    )
                    print("created new recurring goal")
                    dismiss()
                case .target:
                    targetGoalViewModel.addGoal(name: name, exerciseId: relatedExerciseId!, type: targetType, targetPrimaryValue: primaryValue, targetSecondaryValue: secondaryValue, startDate: startDate
                    )
                    print("created new target goal")
                    dismiss()
                }
                
            } label: {
                Text("Create Goal")
                    .padding(14)
            }.disabled(isDisabled)
        }
    }
    
    private var isDisabled: Bool {
        switch type {
        case .recurring:
            return name.isEmpty || target == 0
        case .target:
            return name.isEmpty || primaryValue == 0 || secondaryValue == 0 || relatedExerciseId == nil
        }
    }
}

#Preview {
    
    NavigationStack{
        NewGoalView()
            .navigationTitle(Text("New Goal"))
    }
    
}
