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
    var rating: Int?

    @Relationship(deleteRule: .cascade) var exercises: [Exercise] = []
    
    init(id: UUID = UUID(),
         name: String,
         startTime: Date,
         endTime: Date? = nil,
         weight: Double? = nil,
         notes: String? = nil,
         rating: Int? = nil) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.weight = weight
        self.notes = notes
        self.rating = rating
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
    
    static let sampleData = [
        Workout(name: "Chest Day", startTime: Date().addingTimeInterval(-3600), endTime: Date(), weight: 150.0, notes: "Good Lift", rating: 5),
        Workout(name: "Leg Day", startTime: Date().addingTimeInterval(-4600), endTime: Date().addingTimeInterval(-1000), weight: 160.0, notes: "Good Lift", rating: 4),
        Workout(name: "Arm Day", startTime: Date().addingTimeInterval(-5600), endTime: Date().addingTimeInterval(-2000), weight: 170.0, notes: "Good Lift", rating: 3),
        Workout(name: "Back Day", startTime: Date().addingTimeInterval(-6600), endTime: Date().addingTimeInterval(-3000), weight: 180.0, notes: "Good Lift", rating: 2),
        
    ]
}
