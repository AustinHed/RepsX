//
//  PredefinedExercises.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import Foundation
import SwiftData

@Model
class ExerciseTemplate: Identifiable {
    var id: UUID
    var name: String
    var category: CategoryModel
    var hidden: Bool
    
    init(id: UUID = UUID(),
         name: String = "Unknown Exercise",
         category: CategoryModel = CategoryModel(name: "Other"),
         hidden: Bool = false
        ){
        self.id = id
        self.name = name
        self.category = category
        self.hidden = hidden
    }
}
