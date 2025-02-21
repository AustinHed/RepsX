//
//  Workout.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//
import Foundation
import SwiftData

//TODO: Add documentation
@Model
class Workout {
    var id: UUID
    var name: String
    var startTime: Date
    var endTime: Date?      // Now optional
    var weight: Double?     // Optional bodyweight in lbs
    var notes: String?      // Optional workout notes

    @Relationship(deleteRule: .cascade) var exercises: [Exercise] = []
    
    init(id: UUID = UUID(),
         name: String,
         startTime: Date,
         endTime: Date? = nil,
         weight: Double? = nil,
         notes: String? = nil) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.weight = weight
        self.notes = notes
    }
    
    /// Computed property that returns the workout length (in seconds).
    /// If endTime is nil or is before startTime, returns 0.
    var workoutLength: TimeInterval {
        if let end = endTime, end > startTime {
            return end.timeIntervalSince(startTime)
        } else {
            return 0
        }
    }
}
