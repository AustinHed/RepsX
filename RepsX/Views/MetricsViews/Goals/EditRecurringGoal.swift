//
//  EditConsistecyGoal.swift
//  RepsX
//
//  Created by Austin Hed on 4/14/25.
//

import SwiftUI
import Foundation
import SwiftData

struct EditRecurringGoal: View {
    
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    
    let goal:ConsistencyGoal
    //let workouts: [Workout]
    
    @State var newName: String = ""
    @State var newTarget: Double
    
    @State var showAlert: Bool = false
    
    //custom init to grab goal.goalTarget and use it as newTarget starting value
    init(goal: ConsistencyGoal, workouts: [Workout]){
        self.goal = goal
        //self.workouts = workouts
        _newTarget = State(initialValue: goal.goalTarget)
    }
    
    var body: some View {
        ScrollView{
            LazyVStack (alignment:.leading, spacing: 12){
                
                Text("Details")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .padding(.leading,3)
                //edit name
                editName
                
                //edit target
                editTarget
                
                //history
                historyHeader
                .padding(.leading,3)
                .padding(.trailing,3)
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.white)
                    let allPeriods = [consistencyGoalViewModel.currentPeriod(for: goal)] + consistencyGoalViewModel.previousPeriods(for: goal)
                    VStack{
                        ForEach(allPeriods, id: \.start) { period in
                            progressRow(goal: goal, workouts: workouts, period: period)
                            //divider
                            Divider()
                                .padding(.leading,15)
                        }
                    }
                    
                }
                
                
                Text("Delete")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .padding(.leading,3)
                //Delete goal
                delete
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("Edit Goal")
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
        .toolbar {
            //only show a save button if the user actually made changes
            if !newName.isEmpty || newTarget != goal.goalTarget {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //save - actually update the GoalModel
                        consistencyGoalViewModel.updateGoal(goal,
                                                            newName: newName.isEmpty ? nil : newName,
                                                            newTarget: newTarget)
                        dismiss()
                    } label: {
                        Text("Save")
                            .bold()
                    }
                }
            }
            
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
    }
}
//MARK: Edit name
extension EditRecurringGoal {
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
extension EditRecurringGoal {
    var periodName: String {
        switch goal.goalTimeframe {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        }
    }
    var editTarget: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            HStack{
                TextField("\(goal.goalTarget)", value: $newTarget, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 40)
                switch goal.goalMeasurement {
                case .minutes:
                    Text("mins every \(periodName)")
                        .foregroundStyle(.secondary)
                case .workouts:
                    Text("workouts every \(periodName)")
                        .foregroundStyle(.secondary)
                case .reps:
                    Text("reps every \(periodName)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                    
            }
            .padding()
        }
    }
}

//MARK: goal history
extension EditRecurringGoal {
    var historyHeader: some View {
        HStack{
            Text("History")
                .font(.headline)
                .bold()
                .foregroundStyle(.black)
            Spacer()
            Text("\(consistencyGoalViewModel.currentStreak(for: goal, from: workouts)) \(periodName) streak")
                .font(.headline)
                .bold()
                .foregroundStyle(.black)
        }
        
    }
    //period header text
    func periodLabel(for period: Period) -> String {
        let calendar = Calendar.current
        switch goal.goalTimeframe {
        case .daily:
            return period.start.formatted(.dateTime.month(.abbreviated).day().year())
        case .weekly:
            // e.g., "Apr 11 - Apr 18, 2025"
            let startStr = period.start.formatted(.dateTime.month(.abbreviated).day())
            // Subtract one day from 'end' since it's the start of the next period
            let inclusiveEnd = calendar.date(
                byAdding: .day,
                value: -1,
                to: period.end
            ) ?? period.end
            let endStr = inclusiveEnd.formatted(.dateTime.month(.abbreviated).day().year())
            return "\(startStr) - \(endStr)"
        case .monthly:
            // e.g., "Apr, 2025"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM, yyyy"
            return formatter.string(from: period.start)
        }
    }
    func progressRow(goal: ConsistencyGoal,
                           workouts: [Workout],
                           period: Period
    ) -> some View {
        let target = goal.goalTarget
        let progress = consistencyGoalViewModel.progress(in: period, for: goal, from: workouts)
        return VStack(alignment:.leading) {
            //header
            Text(periodLabel(for: period))
                .font(.headline)
                .padding(.horizontal)
            //x out of y
            Text("\(progress, specifier: "%.0f") out of \(target, specifier: "%.0f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            //progress bar
            ProgressView(value: progress, total: target)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal)
        }
        .padding(.vertical,10)
    }
    
}

//MARK: delete
extension EditRecurringGoal {
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
        EditRecurringGoal(goal: testGoal, workouts: workouts)
    }
    
    
}

//used to determine goal periods
struct Period {
  let start: Date
  let end: Date
}
