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
    
    
    // MARK: - Add Predefined Exercise
    /// Creates a new PredefinedExercise with the given name and category, inserts it into the context, saves, and returns it.
    func addPredefinedExercise(name: String, category: CategoryModel) -> ExerciseTemplate {
        let newExercise = ExerciseTemplate(name: name, category: category)
        modelContext.insert(newExercise)
        save()
        return newExercise
    }
    
    // MARK: - Update Predefined Exercise
    /// Updates the given PredefinedExercise with a new name and/or category.
    func updatePredefinedExercise(_ exercise: ExerciseTemplate, newName: String? = nil, newCategory: CategoryModel? = nil) {
        if let newName = newName {
            exercise.name = newName
        }
        if let newCategory = newCategory {
            exercise.category = newCategory
        }
        save()
    }
    
    // MARK: - Delete Predefined Exercise
    /// Deletes the provided PredefinedExercise from the context.
    func deletePredefinedExercise(_ exercise: ExerciseTemplate) {
        modelContext.delete(exercise)
        save()
    }
    
    // MARK: - Fetch Predefined Exercises
    /// Returns all stored PredefinedExercises, sorted alphabetically by name.
    func fetchPredefinedExercises() -> [ExerciseTemplate] {
        let descriptor = FetchDescriptor<ExerciseTemplate>(sortBy: [SortDescriptor(\.name)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching predefined exercises: \(error.localizedDescription)")
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
    func initializeDefaultPredefinedExercisesIfNeeded() {
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


