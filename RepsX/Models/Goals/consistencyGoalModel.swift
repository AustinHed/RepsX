//
//  GoalsModel.swift
//  RepsX
//
//  Created by Austin Hed on 4/11/25.
//

import SwiftData
import Foundation
import SwiftUI

//weekly or monthly goals
enum GoalTimeframe: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

//calculating different timeframes / periods for a goal
extension GoalTimeframe {
    /// Returns the date at which the current period began,
    /// e.g. midnight for .daily, the most recent Sunday for .weekly,
    /// or the first of the month for .monthly.
    func startOfPeriod(containing date: Date, calendar: Calendar = .current) -> Date {
      var cal = calendar
      cal.firstWeekday = 1  // Sunday = 1
      
      switch self {
      case .daily:
        return cal.startOfDay(for: date)
        
      case .weekly:
        // extract yearForWeekOfYear & weekOfYear, then rebuild
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps)!
        
      case .monthly:
        // extract year & month, then rebuild
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps)!
      }
    }
    
    /// The calendar component you add/subtract to move one period.
    var movingComponent: Calendar.Component {
      switch self {
      case .daily:   return .day
      case .weekly:  return .weekOfYear
      case .monthly: return .month
      }
    }
}

//whats tracked - minutes worked out, workouts logged, or reps for an exercise performed
enum GoalMeasurement: String, CaseIterable, Codable {
    case minutes = "Minutes"
    case workouts = "Workouts"
    case reps = "Reps"
}

@Model
class ConsistencyGoal: Hashable, Equatable {
    
    //TODO: compute name based off inputs
    var id: UUID
    var name: String //what the user sees
    var goalTimeframe: GoalTimeframe //how often this goal is measured. ex. 50 minutes of exercise "per week"
    var goalMeasurement: GoalMeasurement //what to measure. ex. 50 "minutes" of exercise per week
    var goalTarget: Double //the target. ex. "50" minutes of exercise per week
    var exerciseId: UUID? //if associated with a specific exercise, the UUID of that exercise
    var startDate: Date
    var isCompleted: Bool
    
    //initialize the instance
    init(id: UUID = UUID(),
         name: String,
         goalTimeframe: GoalTimeframe,
         goalMeasurement: GoalMeasurement,
         goalTarget: Double,
         exerciseId: UUID? = nil,
         startDate: Date,
         isCompleted: Bool
    ) {
        self.id = id
        self.name = name
        self.goalTimeframe = goalTimeframe
        self.goalMeasurement = goalMeasurement
        self.goalTarget = goalTarget
        self.exerciseId = exerciseId
        self.startDate = startDate
        self.isCompleted = isCompleted
    }
}
