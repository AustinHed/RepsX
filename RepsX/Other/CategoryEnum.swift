//
//  CategoryEnum.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import Foundation
import SwiftData
//@Model
//class workoutCategory {
//    @Attribute(.unique) var name: String
//    @Relationship(deleteRule: .cascade, inverse: \Exercise.category)
//    var workouts = [Exercise()]
//}

enum Category: String, CaseIterable, Codable {
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case shoulders = "Shoulders"
    case other = "Other"
    
    //init
    init() {
        self = .other
    }
}
