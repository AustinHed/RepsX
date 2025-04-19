//
//  ExerciseTypeEnum.swift
//  RepsX
//
//  Created by Austin Hed on 3/1/25.
//

import Foundation
import SwiftData

//tracks the modality of a workout (how it is performed)
enum ExerciseModality: String, CaseIterable, Codable {
    case repetition = "repetition" //ex bench, which is reps and weight
    case endurance = "endurance" //ex. running, which is time and distance
    
    //init
    init() {
        self = .repetition //default to reps and weight
    }
}
