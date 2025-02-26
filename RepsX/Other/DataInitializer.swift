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
        let exerciseDescriptor = FetchDescriptor<PredefinedExercise>()
        let existingExercises = try context.fetch(exerciseDescriptor)
        
        if existingExercises.isEmpty {
            var defaultExercises: [PredefinedExercise] = []
            
            if let chestCat = defaultCategories.first(where: { $0.name == "Chest" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Bench Press", category: chestCat),
                    PredefinedExercise(name: "Incline Dumbbell Press", category: chestCat),
                    PredefinedExercise(name: "Decline Press", category: chestCat),
                    PredefinedExercise(name: "Cable Fly", category: chestCat),
                    PredefinedExercise(name: "Chest Dips", category: chestCat)
                ])
            }
            if let legsCat = defaultCategories.first(where: { $0.name == "Legs" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Squat", category: legsCat),
                    PredefinedExercise(name: "Leg Press", category: legsCat),
                    PredefinedExercise(name: "Walking Lunge", category: legsCat),
                    PredefinedExercise(name: "Leg Extension", category: legsCat),
                    PredefinedExercise(name: "Hamstring Curl", category: legsCat)
                ])
            }
            if let backCat = defaultCategories.first(where: { $0.name == "Back" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Deadlift", category: backCat),
                    PredefinedExercise(name: "Pull-Up", category: backCat),
                    PredefinedExercise(name: "Barbell Row", category: backCat),
                    PredefinedExercise(name: "Lat Pulldown", category: backCat),
                    PredefinedExercise(name: "Seated Cable Row", category: backCat)
                ])
            }
            if let shouldersCat = defaultCategories.first(where: { $0.name == "Shoulders" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Overhead Press", category: shouldersCat),
                    PredefinedExercise(name: "Lateral Raise", category: shouldersCat),
                    PredefinedExercise(name: "Front Raise", category: shouldersCat),
                    PredefinedExercise(name: "Reverse Fly", category: shouldersCat),
                    PredefinedExercise(name: "Arnold Press", category: shouldersCat)
                ])
            }
            if let armsCat = defaultCategories.first(where: { $0.name == "Arms" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Bicep Curl", category: armsCat),
                    PredefinedExercise(name: "Hammer Curl", category: armsCat),
                    PredefinedExercise(name: "Tricep Pushdown", category: armsCat),
                    PredefinedExercise(name: "Skullcrusher", category: armsCat),
                    PredefinedExercise(name: "Cable Curl", category: armsCat)
                ])
            }
            if let coreCat = defaultCategories.first(where: { $0.name == "Core" }) {
                defaultExercises.append(contentsOf: [
                    PredefinedExercise(name: "Plank", category: coreCat),
                    PredefinedExercise(name: "Crunch", category: coreCat),
                    PredefinedExercise(name: "Russian Twist", category: coreCat),
                    PredefinedExercise(name: "Leg Raise", category: coreCat),
                    PredefinedExercise(name: "Mountain Climber", category: coreCat)
                ])
            }
            
            defaultExercises.forEach { context.insert($0) }
        }
        
        try context.save()
    } catch {
        print("Error initializing default data: \(error.localizedDescription)")
    }
}
