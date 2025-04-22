//
//  targetGoalModel.swift
//  RepsX
//
//  Created by Austin Hed on 4/16/25.
//

import SwiftData
import Foundation



@Model
class TargetGoal: Identifiable {
    var id: UUID
    var name: String            // e.g. "Bench Press Max"
    var exerciseId: UUID        // which exercise template
    
    var type: TargetGoalType            // strength or pace
    //these are "Do X, in Y"
    var targetPrimaryValue: Double     // ex. 225 lbs, or 100 meters
    var targetSecondaryValue: Double     // ex. 5 reps, or 10 seconds
    
    var startDate: Date         // when the goal was set

    init(id: UUID = UUID(),
         name: String,
         exerciseId: UUID,
         
         type: TargetGoalType,
         targetPrimaryValue: Double,
         targetSecondaryValue: Double,
         
         startDate: Date = Date())
    {
        self.id = id
        self.name = name
        self.exerciseId = exerciseId
        
        self.type = type
        self.targetPrimaryValue = targetPrimaryValue
        self.targetSecondaryValue = targetSecondaryValue
        
        self.startDate = startDate
    }
}
