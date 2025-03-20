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
    var modality: ExerciseModality
    var hidden: Bool
    var standard: Bool
    
    init(id: UUID = UUID(),
         name: String = "Unknown Exercise",
         category: CategoryModel = CategoryModel(name: "Other"),
         modality: ExerciseModality = .repetition, //defaults to reps and weight modality
         hidden: Bool = false, //defaults to the "nonhidden / non deleted" state
         standard: Bool = false
        ){
        self.id = id
        self.name = name
        self.modality = modality 
        self.category = category
        self.hidden = hidden
        self.standard = standard
    }
}
