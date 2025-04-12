//
//  NewConsistencyGoalView.swift
//  RepsX
//
//  Created by Austin Hed on 4/11/25.
//

import SwiftUI
import SwiftData
import Foundation

struct NewConsistencyGoalView: View {
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) var dismiss
    
    //view model
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    
    //the new goal properties
    @State var name: String = ""
    @State var measurement: GoalMeasurement = .minutes
    @State var timeframe: GoalTimeframe = .weekly
    @State var target: Double = 0.0
    @State var relatedExerciseId: UUID? = nil
    @State var relatedExerciseName: String? = nil
    @State var startDate: Date = Date()
    
    //Show time picker
    @State var showDatePicker: Bool = false
    //Show exercise picke
    @State var showExercisePicker: Bool = false
    
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading, spacing: 12){
                //Name entry
                nameEntry
                
                //Details
                detailsSection
                
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
            .tint(themeColor)
        }
        //MARK: Alert
        //are you sure you want to dismiss alert
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
//MARK: Name entry
extension NewConsistencyGoalView {
    var nameEntry: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
            //textEntry
            TextField("Name", text: $name)
                .padding()
        }
    }
}

//MARK: Details
extension NewConsistencyGoalView {
    var detailsSection: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
            VStack(alignment:.leading){
                //Measure
                HStack (alignment:.center) {
                    Text("Measure")
                        .font(.headline)
                        .bold()
                        .padding(.leading)
                        .frame(width: 100, alignment:.leading)
                        
                    CustomGoalPicker<GoalMeasurement>(selection: $measurement)
                        .padding(.horizontal)
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
                        
                    
                    
                    CustomGoalPicker<GoalTimeframe>(selection: $timeframe)
                        .padding(.horizontal)
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
                            Text(relatedExerciseName != nil ? relatedExerciseName! :"No Exercise Name")
                                .padding(.trailing, 5)
                        }

                    }
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
                    case .weekly:
                        Text("every week")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    case .monthly:
                        Text("every month")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                .padding(.top,5)
                
            }
            
        }
    }
}

//MARK: Start Date
extension NewConsistencyGoalView {
    var startDateSection: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
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
    @Environment(\.themeColor) var themeColor: Color
    @Environment(\.dismiss) var dismiss
    @Binding var startDate: Date
    
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
                    .foregroundStyle(themeColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(themeColor)
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
    }
}

//MARK: Create button
extension NewConsistencyGoalView {
    var createGoalButton: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
            
            Button {
                //action
                consistencyGoalViewModel.addGoal(name: name,
                                                 goalTimeframe: timeframe,
                                                 goalMeasurement: measurement,
                                                 goalTarget: target,
                                                 exerciseId: measurement == .reps ? relatedExerciseId : nil,
                                                 startDate: startDate
                )
                print("created new goal")
                dismiss()
            } label: {
                Text("Create Goal")
                    .padding(10)
            }.disabled(name.isEmpty || target == 0)
        }
    }
}

#Preview {
    
    NavigationStack{
        NewConsistencyGoalView()
            .navigationTitle(Text("New Goal"))
    }
    
}
