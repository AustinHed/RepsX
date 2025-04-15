//
//  consistencyGoalViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 4/11/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ConsistencyGoalViewModel {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //add
    func addGoal(name: String,
                     goalTimeframe: GoalTimeframe,
                     goalMeasurement: GoalMeasurement,
                     goalTarget: Double,
                     exerciseId: UUID? = nil,
                     startDate: Date
    )  {
        let newConsistencyGoal = ConsistencyGoal(name: name,
                                                 goalTimeframe: goalTimeframe,
                                                 goalMeasurement: goalMeasurement,
                                                 goalTarget: goalTarget,
                                                 exerciseId: exerciseId,
                                                 startDate: startDate,
                                                 isCompleted: false
        )
        modelContext.insert(newConsistencyGoal)
        print(newConsistencyGoal)
        save()
    }
    
    //delete
    func deleteGoal(_ goal: ConsistencyGoal) {
        //first, delete goal
        modelContext.delete(goal)
        //then, save
        save()
    }
    
    //update
    func updateGoal(_ goal: ConsistencyGoal, newTimeframe: GoalTimeframe? = nil, newMeasurement: GoalMeasurement? = nil, newTarget: Double? = nil, isCompleted: Bool? = nil) {
        
        if let newTimeframe = newTimeframe {
            goal.goalTimeframe = newTimeframe
        }
        if let newMeasurement = newMeasurement {
            goal.goalMeasurement = newMeasurement
        }
        if let newTarget = newTarget {
            goal.goalTarget = newTarget
        }
        if let isCompleted = isCompleted {
            goal.isCompleted = isCompleted
        }
        
        save()
    }
    
    //calculate progress
    func progress(for goal: ConsistencyGoal, from workouts: [Workout]) -> Double {
        //determine the period start, based on the goal.goalTimeframe
        let calendar = Calendar.current
        let periodStart: Date
        
        //defining when to measure goal progress (ex. today, last week, last month)
        switch goal.goalTimeframe {
        case .daily:
            periodStart = calendar.startOfDay(for: Date())
        case .weekly:
            //first, ensure that Sunday is considered the first day of a calendar week
            var calendarWithSundayFirst = calendar
            calendarWithSundayFirst.firstWeekday = 1
            
            //calculate the start of the week
            let components = calendarWithSundayFirst.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            periodStart = calendarWithSundayFirst.date(from:components) ?? Date()
        case .monthly:
            //first, create the calendar components
            let components = calendar.dateComponents([.year, .month], from: Date())
            periodStart = calendar.date(from: components) ?? Date()
        }
        
        //define the workouts to leverage
        let workoutsInPeriod = workouts.filter {workout in
            //assumption is there are no workouts in the future
            workout.startTime >= periodStart
        }
        
        //calculate progress, depending on how progress is measured (ex. minutes, workouts, reps)
        switch goal.goalMeasurement {
        case .minutes:
            //sum all workout lengths in the period
            let totalMinutes = workoutsInPeriod.reduce(0) { sum, workout in
                sum + (workout.workoutLength/60)
            }
            return totalMinutes
        
        case .workouts:
            //count number of workouts
            return Double(workoutsInPeriod.count)
        
        case .reps:
            //number of reps for a specified exercise
            if goal.exerciseId != nil {
                let filteredExercises = workouts.flatMap {$0.exercises}
                    .filter {$0.templateId == goal.exerciseId}
                let allSets = filteredExercises.flatMap {$0.sets}
                
                let totalReps = allSets.reduce(0) {sum, set in
                    sum + (set.reps)
                }
                return Double(totalReps)
            } else {
                return 0
            }
        }
    }
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving consistency goal: \(error.localizedDescription)")
        }
    }
}
