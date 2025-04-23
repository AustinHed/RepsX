//
//  Goals.swift
//  RepsX
//
//  Created by Austin Hed on 4/22/25.
//
import Foundation

//MARK: Recurring
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

//MARK: Target
enum TargetGoalType: String, CaseIterable, Codable {
    case strength = "Strength"
    ///this should always be measured as X weight for Y reps
    case pace = "Pace"
    ///this should always be measured as X miles in Y minutes
}
