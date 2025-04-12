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
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving consistency goal: \(error.localizedDescription)")
        }
    }
}
