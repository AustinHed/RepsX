//
//  EditConsistecyGoal.swift
//  RepsX
//
//  Created by Austin Hed on 4/14/25.
//

import SwiftUI
import Foundation

struct EditConsistencyGoalView: View {
    
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    
    let goal:ConsistencyGoal
    let workouts: [Workout]
    
    @State var newName: String = ""
    @State var newTarget: Double = 0
    
    @State var showAlert: Bool = false
    
    var body: some View {
        ScrollView{
            LazyVStack (alignment:.leading, spacing: 12){
                //edit name
                Text("Details")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .padding(.leading,3)
                editName
                
                //edit target value
                editTarget
                
                //History for a given goal
                HStack{
                    Text("History")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                    Spacer()
                    Text("X week streak")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                }
                .padding(.leading,3)
                .padding(.trailing,3)
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.white)
                    VStack{
                        progressForPeriod(goal: goal, workouts: workouts)
                            .padding(.horizontal)
                            .padding(.vertical,10)
                        Divider()
                            .padding(.leading)
                        
                        progressForPeriod(goal: goal, workouts: workouts)
                            .padding(.horizontal)
                            .padding(.vertical,10)
                        Divider()
                            .padding(.leading)
                        
                        progressForPeriod(goal: goal, workouts: workouts)
                            .padding(.horizontal)
                            .padding(.vertical,10)
                            .padding(.bottom,10)
                    }
                    
                    
                    
                }
                
                //Delete goal
                Text("Delete")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .padding(.leading,3)
                delete
                
                
                
                
                
            }
        }
        .padding(.horizontal)
        .navigationTitle("Edit Goal")
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 50)
        }
        .alert("Delete this Goal?", isPresented: $showAlert) {
                    Button("Cancel", role: .cancel) {
                        // Cancel action: simply dismiss the alert.
                        showAlert = false
                    }
                    Button("Delete", role: .destructive) {
                        // Confirm delete action: handle the deletion here.
                        consistencyGoalViewModel.deleteGoal(goal)
                        showAlert = false
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this goal? This cannot be undone.")
                }
        //TODO: add "back" and "save" buttons to toolbar
        
        
        /*
         show past days/weeks/months, based on the Start Date
         */
    }
}
//MARK: Edit name
extension EditConsistencyGoalView {
    var editName: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            ZStack (alignment:.leading){
                if newName.isEmpty {
                    Text(goal.name)
                        .foregroundStyle(.black)
                        .padding(.leading, 16)
                }
                TextField("", text: $newName)
                    .padding()
            }
            
        }
    }
}
//MARK: Edit target
extension EditConsistencyGoalView {
    var editTarget: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            HStack{
                //TODO: dont default to showing 0, show the existing target value
                TextField("\(goal.goalTarget)", value: $newTarget, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 40)
                    .border(.red)
                switch goal.goalMeasurement {
                case .minutes:
                    switch goal.goalTimeframe {
                    case .daily:
                        Text("mins every day")
                            .foregroundStyle(.secondary)
                    case .weekly:
                        Text("mins every week")
                            .foregroundStyle(.secondary)
                    case .monthly:
                        Text("mins every month")
                            .foregroundStyle(.secondary)
                    }
                case .workouts:
                    switch goal.goalTimeframe {
                    case .daily:
                        Text("workouts every day")
                            .foregroundStyle(.secondary)
                    case .weekly:
                        Text("workouts every week")
                            .foregroundStyle(.secondary)
                    case .monthly:
                        Text("workouts every month")
                            .foregroundStyle(.secondary)
                    }
                case .reps:
                    switch goal.goalTimeframe {
                    case .daily:
                        Text("reps every day")
                            .foregroundStyle(.secondary)
                    case .weekly:
                        Text("reps every week")
                            .foregroundStyle(.secondary)
                    case .monthly:
                        Text("reps every month")
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                    
            }
            .padding()
        }
    }
}

//MARK: goal period
extension EditConsistencyGoalView {
    //TODO: This should be a reusable component to show a given periods progress/status
    func progressForPeriod(goal: ConsistencyGoal, workouts: [Workout]) -> some View {
        return VStack(alignment:.leading) {
            Text("The given time period")
                .font(.headline)
            Text("XX out of YY")
            ProgressView(value: 1, total: 10)
                .progressViewStyle(LinearProgressViewStyle())
            
        }
    }
}
//MARK: goal history
//todo

//MARK: delete
extension EditConsistencyGoalView {
    var delete: some View {
        return ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            Button {
                showAlert.toggle()
            } label: {
                Spacer()
                Text("Delete Goal")
                    .padding(15)
                Spacer()
            }

        }
    }
}




#Preview {
    let testGoal: ConsistencyGoal = ConsistencyGoal(name: "20 Workouts per Month", goalTimeframe: .weekly, goalMeasurement: .minutes, goalTarget: 20.0, startDate: Date(), isCompleted: false)
    let workouts: [Workout] = []
    NavigationStack{
        EditConsistencyGoalView(goal: testGoal, workouts: workouts)
    }
    
    
}
