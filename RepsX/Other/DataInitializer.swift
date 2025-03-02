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
        // MARK: - Categories
        
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
        
        // MARK: - Exercise Templates
        
        // Fetch existing predefined exercises.
        let exerciseDescriptor = FetchDescriptor<ExerciseTemplate>()
        let existingExercises = try context.fetch(exerciseDescriptor)
        var allExerciseTemplates: [ExerciseTemplate] = []
        if existingExercises.isEmpty {
            var defaultExercises: [ExerciseTemplate] = []
            
            if let chestCat = defaultCategories.first(where: { $0.name == "Chest" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Bench Press", category: chestCat, modality: .repetition),
                    ExerciseTemplate(name: "Incline Dumbbell Press", category: chestCat, modality: .repetition),
                    ExerciseTemplate(name: "Decline Press", category: chestCat, modality: .repetition),
                    ExerciseTemplate(name: "Cable Fly", category: chestCat, modality: .repetition),
                    ExerciseTemplate(name: "Chest Dips", category: chestCat, modality: .repetition)
                ])
            }
            if let legsCat = defaultCategories.first(where: { $0.name == "Legs" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Squat", category: legsCat, modality: .repetition),
                    ExerciseTemplate(name: "Leg Press", category: legsCat, modality: .repetition),
                    ExerciseTemplate(name: "Walking Lunge", category: legsCat, modality: .repetition),
                    ExerciseTemplate(name: "Leg Extension", category: legsCat, modality: .repetition),
                    ExerciseTemplate(name: "Hamstring Curl", category: legsCat, modality: .repetition)
                ])
            }
            if let backCat = defaultCategories.first(where: { $0.name == "Back" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Deadlift", category: backCat, modality: .repetition),
                    ExerciseTemplate(name: "Pull-Up", category: backCat, modality: .repetition),
                    ExerciseTemplate(name: "Barbell Row", category: backCat, modality: .repetition),
                    ExerciseTemplate(name: "Lat Pulldown", category: backCat, modality: .repetition),
                    ExerciseTemplate(name: "Seated Cable Row", category: backCat, modality: .repetition)
                ])
            }
            if let shouldersCat = defaultCategories.first(where: { $0.name == "Shoulders" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Overhead Press", category: shouldersCat, modality: .repetition),
                    ExerciseTemplate(name: "Lateral Raise", category: shouldersCat, modality: .repetition),
                    ExerciseTemplate(name: "Front Raise", category: shouldersCat, modality: .repetition),
                    ExerciseTemplate(name: "Reverse Fly", category: shouldersCat, modality: .repetition),
                    ExerciseTemplate(name: "Arnold Press", category: shouldersCat, modality: .repetition)
                ])
            }
            if let armsCat = defaultCategories.first(where: { $0.name == "Arms" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Bicep Curl", category: armsCat, modality: .repetition),
                    ExerciseTemplate(name: "Hammer Curl", category: armsCat, modality: .repetition),
                    ExerciseTemplate(name: "Tricep Pushdown", category: armsCat, modality: .repetition),
                    ExerciseTemplate(name: "Skullcrusher", category: armsCat, modality: .repetition),
                    ExerciseTemplate(name: "Cable Curl", category: armsCat, modality: .repetition)
                ])
            }
            if let coreCat = defaultCategories.first(where: { $0.name == "Core" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Plank", category: coreCat, modality: .repetition),
                    ExerciseTemplate(name: "Crunch", category: coreCat, modality: .repetition),
                    ExerciseTemplate(name: "Russian Twist", category: coreCat, modality: .repetition),
                    ExerciseTemplate(name: "Leg Raise", category: coreCat, modality: .repetition),
                    ExerciseTemplate(name: "Mountain Climber", category: coreCat, modality: .repetition)
                ])
            }
            
            defaultExercises.forEach { context.insert($0) }
            allExerciseTemplates = defaultExercises
        } else {
            allExerciseTemplates = existingExercises
        }
        
        // MARK: - Default Routines
        
        let routineDescriptor = FetchDescriptor<Routine>()
        let existingRoutines = try context.fetch(routineDescriptor)
        if existingRoutines.isEmpty {
            // Helper function for looking up an exercise template by name.
            func template(named name: String) -> ExerciseTemplate? {
                return allExerciseTemplates.first { $0.name == name }
            }
            
            // Upper Body Routine
            let upperBodyExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Incline Dumbbell Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Bicep Curl"), setCount: 3)
            ]
            let upperBodyRoutine = Routine(
                name: "Upper Body",
                colorHex: "#FF5733",
                exercises: upperBodyExercises,
                favorite: false
            )
            
            // Lower Body Routine
            let lowerBodyExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Leg Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Walking Lunge"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Hamstring Curl"), setCount: 3)
            ]
            let lowerBodyRoutine = Routine(
                name: "Lower Body",
                colorHex: "#33FF57",
                exercises: lowerBodyExercises,
                favorite: false
            )
            
            // Push Routine
            let pushExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Incline Dumbbell Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Tricep Pushdown"), setCount: 3)
            ]
            let pushRoutine = Routine(
                name: "Push",
                colorHex: "#3357FF",
                exercises: pushExercises,
                favorite: false
            )
            
            // Pull Routine
            let pullExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Lat Pulldown"), setCount: 3)
            ]
            let pullRoutine = Routine(
                name: "Pull",
                colorHex: "#FF33A8",
                exercises: pullExercises,
                favorite: false
            )
            
            // Full Body Routine
            let fullBodyExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3)
            ]
            let fullBodyRoutine = Routine(
                name: "Full Body",
                colorHex: "#8D33FF",
                exercises: fullBodyExercises,
                favorite: false
            )
            
            // Insert all routines.
            [upperBodyRoutine, lowerBodyRoutine, pushRoutine, pullRoutine, fullBodyRoutine].forEach { context.insert($0) }
        }
        
        // Save all changes in one transaction.
        try context.save()
        
    } catch {
        print("Error initializing default data: \(error.localizedDescription)")
    }
}
