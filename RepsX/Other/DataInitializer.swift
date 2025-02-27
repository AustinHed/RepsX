//
//  defaultData.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.
//

// DataInitializer.swift

import SwiftData

func initializeDefaultDataIfNeeded(context: ModelContext) {
    do {
        // Fetch existing categories.
        let categoryDescriptor = FetchDescriptor<CategoryModel>()
        let existingCategories = try context.fetch(categoryDescriptor)
        
        var defaultCategories: [CategoryModel] = []
        if existingCategories.isEmpty {
            // Create six default categories.
            defaultCategories = [
                CategoryModel(name: "Chest"),
                CategoryModel(name: "Legs"),
                CategoryModel(name: "Back"),
                CategoryModel(name: "Shoulders"),
                CategoryModel(name: "Arms"),
                CategoryModel(name: "Core")
            ]
            defaultCategories.forEach { context.insert($0) }
        } else {
            defaultCategories = existingCategories
        }
        
        // Fetch existing predefined exercises.
        let exerciseDescriptor = FetchDescriptor<ExerciseTemplate>()
        let existingExercises = try context.fetch(exerciseDescriptor)
        
        if existingExercises.isEmpty {
            var defaultExercises: [ExerciseTemplate] = []
            
            if let chestCat = defaultCategories.first(where: { $0.name == "Chest" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Bench Press", category: chestCat),
                    ExerciseTemplate(name: "Incline Dumbbell Press", category: chestCat),
                    ExerciseTemplate(name: "Decline Press", category: chestCat),
                    ExerciseTemplate(name: "Cable Fly", category: chestCat),
                    ExerciseTemplate(name: "Chest Dips", category: chestCat)
                ])
            }
            if let legsCat = defaultCategories.first(where: { $0.name == "Legs" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Squat", category: legsCat),
                    ExerciseTemplate(name: "Leg Press", category: legsCat),
                    ExerciseTemplate(name: "Walking Lunge", category: legsCat),
                    ExerciseTemplate(name: "Leg Extension", category: legsCat),
                    ExerciseTemplate(name: "Hamstring Curl", category: legsCat)
                ])
            }
            if let backCat = defaultCategories.first(where: { $0.name == "Back" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Deadlift", category: backCat),
                    ExerciseTemplate(name: "Pull-Up", category: backCat),
                    ExerciseTemplate(name: "Barbell Row", category: backCat),
                    ExerciseTemplate(name: "Lat Pulldown", category: backCat),
                    ExerciseTemplate(name: "Seated Cable Row", category: backCat)
                ])
            }
            if let shouldersCat = defaultCategories.first(where: { $0.name == "Shoulders" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Overhead Press", category: shouldersCat),
                    ExerciseTemplate(name: "Lateral Raise", category: shouldersCat),
                    ExerciseTemplate(name: "Front Raise", category: shouldersCat),
                    ExerciseTemplate(name: "Reverse Fly", category: shouldersCat),
                    ExerciseTemplate(name: "Arnold Press", category: shouldersCat)
                ])
            }
            if let armsCat = defaultCategories.first(where: { $0.name == "Arms" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Bicep Curl", category: armsCat),
                    ExerciseTemplate(name: "Hammer Curl", category: armsCat),
                    ExerciseTemplate(name: "Tricep Pushdown", category: armsCat),
                    ExerciseTemplate(name: "Skullcrusher", category: armsCat),
                    ExerciseTemplate(name: "Cable Curl", category: armsCat)
                ])
            }
            if let coreCat = defaultCategories.first(where: { $0.name == "Core" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Plank", category: coreCat),
                    ExerciseTemplate(name: "Crunch", category: coreCat),
                    ExerciseTemplate(name: "Russian Twist", category: coreCat),
                    ExerciseTemplate(name: "Leg Raise", category: coreCat),
                    ExerciseTemplate(name: "Mountain Climber", category: coreCat)
                ])
            }
            
            defaultExercises.forEach { context.insert($0) }
        }
        
        try context.save()
    } catch {
        print("Error initializing default data: \(error.localizedDescription)")
    }
}
