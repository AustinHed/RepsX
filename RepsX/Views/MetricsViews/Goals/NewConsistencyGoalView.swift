//
//  NewConsistencyGoalView.swift
//  RepsX
//
//  Created by Austin Hed on 4/11/25.
//

import SwiftUI
import SwiftData

struct NewConsistencyGoalView: View {
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    //the new goal properties
    @State var name: String = ""
    @State var measurement: GoalMeasurement = .minutes
    @State var timeframe: GoalTimeframe = .weekly
    @State var target: Double = 0.0
    @State var relatedExerciseId: UUID? = nil
    @State var startDate: Date = Date()
    
    var body: some View {
        List {
            
            //Name
            Section {
                Text("enter goal name")
            } header: {
                Text("Name")
            }
            
            //details
            Section {
                //type
                VStack (alignment: .leading){
                    Text("Metric")
                    Picker("Metric", selection: $measurement){
                        ForEach(GoalMeasurement.allCases, id:\.self){timeframe in
                            Text(timeframe.rawValue)
                                .tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                //timeframe
                VStack (alignment: .leading){
                    Text("Timeframe")
                    Picker("Timeframe", selection: $timeframe){
                        ForEach(GoalTimeframe.allCases, id:\.self){timeframe in
                            Text(timeframe.rawValue)
                                .tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                //value to track / set as goal
                HStack{
                    
                    HStack(alignment: .bottom){
                        Text("\(target, specifier: "%0.1f")")
                        switch measurement {
                        case .minutes:
                            Text("Mins")
                                .font(.caption)
                        case .workouts:
                            Text("Workouts")
                                .font(.caption)
                        case .reps:
                            Text("Reps")
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                    
                    switch timeframe {
                    case .daily:
                        Text("every day")
                    case .weekly:
                        Text("every week")
                    case .monthly:
                        Text("every month")
                    }
                }
                
                
                //select exercise
                if measurement == .reps {
                    //show slideup with exercise template select
                    Text("optional - related exercise")
                }
                
            } header: {
                Text("Details")
            }
            
            //start date
            Section {
                Text("\(startDate)")
            } header: {
                Text("Start Date")
            }
            
            //create button
            Section {
                Button {
                    //action
                } label: {
                    HStack{
                        Spacer()
                        Text("Create")
                        Spacer()
                    }
                    
                }
            }
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

#Preview {
    
    let newGoal = ConsistencyGoal(name: "300 mins per week", goalTimeframe: .weekly, goalMeasurement: .minutes, goalTarget: 300, isCompleted: false)
    
    NavigationStack{
        NewConsistencyGoalView()
            .navigationTitle(Text("New Consistency Goal"))
    }
    
}
