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

//whats tracked - minutes worked out, workouts logged, or reps for an exercise performed
enum GoalMeasurement: String, CaseIterable, Codable {
    case minutes = "minutes"
    case workouts = "workouts"
    case reps = "reps"
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
