//
//  ExerciseTypeEnum.swift
//  RepsX
//
//  Created by Austin Hed on 3/1/25.
//

import Foundation
import SwiftData

enum ExerciseModality: String, CaseIterable, Codable {
    case repetition = "repetition"
    case tension = "tension"
    case endurance = "endurance"
    
    //init
    init() {
        self = .repetition
    }
}
