//
//  PredefinedExercises.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import Foundation
import SwiftData

@Model
class PredefinedExercise: Identifiable {
    var id: UUID
    var name: String
    var category: CategoryModel
    
    init(id: UUID = UUID(),
         name: String = "Unknown Exercise",
         category: CategoryModel = CategoryModel(name: "Other")
        ){
        self.id = id
        self.name = name
        self.category = category
    }
}
