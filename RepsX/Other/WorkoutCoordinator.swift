//
//  WorkoutCoordinator.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import Foundation
import SwiftData

@Observable
final class WorkoutCoordinator{
    
    //singleton, only ever one instance of WorkoutCoordinator
    static let shared = WorkoutCoordinator()
    
    //holds the selected workout
    var currentWorkout: Workout?
    
    //tells LogView whether it should open EditWorkoutView or not
    var showEditWorkout: Bool = false
}
