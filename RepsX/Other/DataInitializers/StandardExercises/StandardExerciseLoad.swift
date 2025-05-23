//
//  StandardExerciseCodableStruct.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import Foundation

struct StandardExerciseDefinition: Codable {
    let id: UUID
    let name: String
    let category: String
}

func loadStandardExercises() -> [StandardExerciseDefinition] {
    guard let url = Bundle.main.url(forResource: "StandardExercises", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([StandardExerciseDefinition].self, from: data) else {
        print("Failed to load standard exercises.")
        return []
    }
    return decoded
}

