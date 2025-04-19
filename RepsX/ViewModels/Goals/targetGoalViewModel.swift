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
class TargetGoalViewModel {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //add
    func addGoal(name: String,
                 exerciseId: UUID,
                 type: TargetGoalType,
                 targetPrimaryValue: Double,
                 targetSecondaryValue: Double,
                 startDate: Date
    )  {
        let newTargetGoal = TargetGoal(name: name, exerciseId: exerciseId, type: type, targetPrimaryValue: targetPrimaryValue, targetSecondaryValue: targetSecondaryValue)
        
        modelContext.insert(newTargetGoal)
        print(newTargetGoal)
        save()
    }
    
    //delete
    func deleteGoal(_ goal: TargetGoal) {
        //first, delete goal
        modelContext.delete(goal)
        //then, save
        save()
    }
    
    //update
    func updateGoal(_ goal: TargetGoal,
                    newName: String? = nil,
                    newPrimaryValue: Double? = nil,
                    newSecondaryValue: Double? = nil
    ) {
        
        if let newName = newName {
            goal.name = newName
        }
        if let newPrimaryValue = newPrimaryValue {
            goal.targetPrimaryValue = newPrimaryValue
        }
        
        if let newSecondaryValue = newSecondaryValue {
            goal.targetSecondaryValue = newSecondaryValue
        }
        
        save()
    }
    
    //calculate progress
    //global progress
    func progress(for goal: TargetGoal, from workouts: [Workout]) -> Double {
        switch goal.type {
            case .strength:
            return strengthProgressFraction(for: goal, from: workouts)
            case .pace:
            return paceProgressFraction(for: goal, from: workouts)
        }
    }
    //strength or pace goal progress
    func strengthProgressFraction(for goal: TargetGoal, from workouts: [Workout]) -> Double {
        //get all sets for the exercise
        let allSets = workouts
            .flatMap(\.exercises)
            .filter{ $0.templateId == goal.exerciseId }
            .flatMap(\.sets)
        //only keep sets with the correct number of reps or more
        let matchingSets = allSets
            .filter{$0.reps >= Int(goal.targetSecondaryValue)}
        //find the best set, as defined by the highest weight
        let bestSet = matchingSets
            .compactMap {$0.weight}
            .max() ?? 0
        //return how close the best set was, maxing out at 1 if it was at or above goal
        return min(bestSet/goal.targetPrimaryValue, 1)
    }
    func paceProgressFraction(for goal: TargetGoal, from workouts: [Workout]) -> Double {
        //unpack goal values
        let targetDistance = goal.targetPrimaryValue
        let targetTime = goal.targetSecondaryValue
        
        //convert target time from Minutes into Seconds
        let targetTimeSeconds = targetTime * 60
        
        //compute the target pace as "seconds per unit of distance"
        let targetPace = targetTimeSeconds / targetDistance
        
        //get all relevant sets based on exerciseId
        let allSets = workouts
            .flatMap(\.exercises)
            .filter{ $0.templateId == goal.exerciseId }
            .flatMap(\.sets)
        
        //filter to only sets that have the minimum required distance
        let validSets = allSets.filter{$0.distance >= targetDistance}
        
        //compute the pace for each of the valid sets
        let paces = validSets.compactMap {set -> Double? in
            let duration = set.time
            let distance = set.distance
            
            //skip any sets with 0 or negative vlaues (ex. runs with no time or distance)
            guard
                distance > 0,
                duration > 0
            else {return nil}
            return duration / distance
        }
        
        //find the best set, by pace
        let bestPace = paces.min() ?? Double.infinity
        let fraction = min(targetPace / bestPace, 1.0)
        return fraction
    }

    
    /// Converts a Double (seconds) into "M:SS" format.
    func formatPace(_ secondsPerUnit: Double) -> String {
        guard secondsPerUnit.isFinite, secondsPerUnit > 0 else {
            return "--:--"
        }
        let mins = Int(secondsPerUnit) / 60
        let secs = Int(secondsPerUnit) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    /// Returns a human-readable progress string for the given target goal.
    func progressDescription(for goal: TargetGoal, from workouts: [Workout]) -> String {
        switch goal.type {
        case .strength:
            // Gather all sets for the exercise
            let allSets = workouts
                .flatMap(\.exercises)
                .filter { $0.templateId == goal.exerciseId }
                .flatMap(\.sets)
            // Only keep sets with at least the target reps
            let repCount = Int(goal.targetSecondaryValue)
            let matching = allSets.filter { $0.reps >= repCount }
            // Find the best weight
            let bestWeight = matching
                .compactMap { $0.weight }
                .max() ?? 0
            let target = goal.targetPrimaryValue
            // Format as "185 / 225 lbs"
            return "\(Int(bestWeight)) / \(Int(target)) lbs"
            
        case .pace:
            // Unpack goal values
            let distance = goal.targetPrimaryValue
            let timeMin = goal.targetSecondaryValue
            // Convert to seconds and compute pace
            let targetSec = timeMin * 60
            let targetPace = targetSec / distance
            // Gather all sets for the exercise
            let allSets = workouts
                .flatMap(\.exercises)
                .filter { $0.templateId == goal.exerciseId }
                .flatMap(\.sets)
            // Filter to full-distance runs
            let full = allSets.filter { $0.distance >= distance }
            // Compute each effort's pace
            let paces = full.compactMap { set -> Double? in
                guard set.distance > 0, set.time > 0 else { return nil }
                return set.time / set.distance
            }
            // Best (fastest) pace
            let bestPace = paces.min() ?? Double.infinity
            // Format both target and best pace as "M:SS"
            let bestStr = formatPace(bestPace)
            let targetStr = formatPace(targetPace)
            // Format as "6:30 / 6:00"
            return "\(bestStr) / \(targetStr)"
        }
    }
    
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving target goal: \(error.localizedDescription)")
        }
    }
}

