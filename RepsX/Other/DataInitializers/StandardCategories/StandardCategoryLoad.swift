//
//  StandardCategoryLoad.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import Foundation

struct StandardCategoryDefinition: Codable {
    let id: UUID
    let name: String
}

func loadStandardCategories() -> [StandardCategoryDefinition] {
    guard let url = Bundle.main.url(forResource: "StandardCategories", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([StandardCategoryDefinition].self, from: data) else {
        print("Failed to load standard categories.")
        return []
    }
    return decoded
}
