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
    var category: Category  
    
    init(id: UUID = UUID(),
         name: String = "Unknown Exercise",
         category: Category = .other
        ){
        self.id = id
        self.name = name
        self.category = category
    }
}
