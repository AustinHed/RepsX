//
//  CategoryEnum.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

//TODO: Maybe this should also be a Model?
import Foundation
import SwiftData

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
