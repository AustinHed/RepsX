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
    func updateGoal(_ goal: ConsistencyGoal, newTimeframe: GoalTimeframe? = nil, newMeasurement: GoalMeasurement? = nil, newName: String? = nil, newTarget: Double? = nil, isCompleted: Bool? = nil) {
        
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
        if let newName = newName {
            goal.name = newName
        }
        
        save()
    }
    
    //current period
    func currentPeriod(for goal: ConsistencyGoal) -> Period {
        let now = Date()
        let calendar = Calendar.current
        
        let start = goal.goalTimeframe.startOfPeriod(containing: now, calendar: calendar)
        let end = calendar.date(byAdding: goal.goalTimeframe.movingComponent,
                                value: 1,
                                to: start)!
        
        return Period(start: start, end: end)
    }
    //previous periods
    func previousPeriods(for goal: ConsistencyGoal) -> [Period] {
        let calendar = Calendar.current
        let now = Date()
        // 1) figure out when *this* period began
        let currentStart = goal.goalTimeframe.startOfPeriod(containing: now, calendar: calendar)
        
        var periods: [Period] = []
        // 2) step backwards one period at a time
        var periodStart = calendar.date(
            byAdding: goal.goalTimeframe.movingComponent,
            value: -1,
            to: currentStart
        )!
        
        while periodStart >= goal.startDate {
            // end = start of *next* period
            let periodEnd = calendar.date(
                byAdding: goal.goalTimeframe.movingComponent,
                value: 1,
                to: periodStart
            )!
            
            periods.append(Period(start: periodStart, end: periodEnd))
            
            // step to the *previous* period
            periodStart = calendar.date(
                byAdding: goal.goalTimeframe.movingComponent,
                value: -1,
                to: periodStart
            )!
        }
        
        // Returns an array from newest → oldest
        return periods
    }
    //calculate progress
    func progress(in period: Period,
                  for goal: ConsistencyGoal,
                  from workouts: [Workout]) -> Double
    {
        // 1) Filter workouts to only those in the period:
        let workoutsInPeriod = workouts.filter { w in
            w.startTime >= period.start && w.startTime < period.end
        }

        // 2) Switch on the measurement type:
        switch goal.goalMeasurement {
        case .minutes:
            // Sum all workoutLength (in seconds) → convert to minutes
            let totalSeconds = workoutsInPeriod.reduce(0) { sum, w in
                sum + w.workoutLength
            }
            return totalSeconds / 60.0

        case .workouts:
            // Just count them
            return Double(workoutsInPeriod.count)

        case .reps:
            // If the goal has an exerciseId, only count that exercise’s reps:
            guard let exerciseId = goal.exerciseId else {
                return 0
            }

            // Flatten all exercises in period, filter by templateId:
            let filteredExercises = workoutsInPeriod
                .flatMap { $0.exercises }
                .filter { $0.templateId == exerciseId }

            // Then flatten to sets and sum reps:
            let totalReps = filteredExercises
                .flatMap { $0.sets }
                .reduce(0) { sum, set in sum + (set.reps) }

            return Double(totalReps)
        }
    }
    //streak
    func currentStreak(for goal: ConsistencyGoal, from workouts: [Workout]) -> Int {
      // 1. Build the list of periods, newest→oldest
      let allPeriods = [ currentPeriod(for: goal) ]
                     + previousPeriods(for: goal)
      
      // 2. Walk through them, stopping at the first miss
      var streak = 0
      for period in allPeriods {
        let progress = progress(in: period,
                                for: goal,
                                from: workouts)
        if progress >= goal.goalTarget {
          streak += 1
        } else {
          break
        }
      }
      
      return streak
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
