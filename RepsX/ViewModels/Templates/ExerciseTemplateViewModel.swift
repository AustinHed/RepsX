//
//  PredefinedExercisesViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ExerciseTemplateViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    // MARK: Add
    /// Creates a new PredefinedExercise with the given name and category, inserts it into the context, saves, and returns it.
    func addExerciseTemplate(name: String, category: CategoryModel, modality: ExerciseModality) -> ExerciseTemplate {
        let newExerciseTemplate = ExerciseTemplate(name: name, category: category, modality: modality)
        modelContext.insert(newExerciseTemplate)
        save()
        return newExerciseTemplate
    }
    
    // MARK: Update
    /// Updates the given PredefinedExercise with a new name and/or category and/or modality
    func updateExerciseTemplate(_ exerciseTemplate: ExerciseTemplate, newName: String? = nil, newCategory: CategoryModel? = nil, newModality: ExerciseModality? = nil) {
        //update name if available
        if let newName = newName {
            exerciseTemplate.name = newName
        }
        //update category if available
        if let newCategory = newCategory {
            exerciseTemplate.category = newCategory
        }
        //update modality if available
        if let newModality = newModality {
            exerciseTemplate.modality = newModality
        }
        save()
    }
    
    // MARK: Delete
    /// Deletes the provided PredefinedExercise from the context.
    func deleteExerciseTemplate(_ exerciseTemplate: ExerciseTemplate) {
        modelContext.delete(exerciseTemplate)
        save()
        /*
         previous - keeping in case i need this again
         //does not delete, but instead marks the exercise as "hidden"
         exerciseTemplate.hidden = true
         //updates the name to include hidden
         exerciseTemplate.name += " (deleted)"
         //modelContext.delete(exercise)
         save()
         */
        
    }
    
    // MARK: - Fetch Predefined Exercises
    /// Returns all stored PredefinedExercises, sorted alphabetically by name.
    func fetchExerciseTemplate() -> [ExerciseTemplate] {
        let descriptor = FetchDescriptor<ExerciseTemplate>(sortBy: [SortDescriptor(\.name)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching exercise templates: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchExercisesForCategory(category: CategoryModel) -> [ExerciseTemplate] {
        let categoryValue = category.id
        let descriptor = FetchDescriptor<ExerciseTemplate>(predicate: #Predicate { exerciseTemplate in
            exerciseTemplate.category.id == categoryValue
        })
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("error fetching exercise templates for category \(category). Error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Save
    /// Saves any changes to the model context.
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving predefined exercise: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: Default Exercises
    ///creates default exercises if none are available
    func initializeDefaultExerciseTemplatesIfNeeded() {
        let descriptor = FetchDescriptor<ExerciseTemplate>()
        do {
            let existingExercises = try modelContext.fetch(descriptor)
            if existingExercises.isEmpty {
                let defaultExercises = [
                    ExerciseTemplate(name: "Bench Press", category: CategoryModel(name: "Chest")),
                    ExerciseTemplate(name: "Squat", category: CategoryModel(name: "Legs")),
                    ExerciseTemplate(name: "Deadlift", category: CategoryModel(name: "Back")),
                    ExerciseTemplate(name: "Overhead Press", category: CategoryModel(name: "Shoulders"))
                ]
                defaultExercises.forEach { modelContext.insert($0) }
                try modelContext.save()
            }
        } catch {
            print("Error checking default predefined exercises: \(error.localizedDescription)")
        }
    }
}


