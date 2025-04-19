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
            // Create default categories.
            defaultCategories = [
                CategoryModel(name: "Chest", standard: true),
                CategoryModel(name: "Back", standard: true),
                CategoryModel(name: "Shoulders", standard: true),
                CategoryModel(name: "Biceps", standard: true),
                CategoryModel(name: "Triceps", standard: true),
                CategoryModel(name: "Forearms", standard: true),
                CategoryModel(name: "Quadriceps", standard: true),
                CategoryModel(name: "Hamstrings", standard: true),
                CategoryModel(name: "Glutes", standard: true),
                CategoryModel(name: "Calves", standard: true),
                CategoryModel(name: "Abdominals", standard: true),
                CategoryModel(name: "Obliques", standard: true)
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
                    ExerciseTemplate(name: "Bench Press", category: chestCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Incline Dumbbell Press", category: chestCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Decline Press", category: chestCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Cable Fly", category: chestCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Chest Dips", category: chestCat, modality: .repetition, standard: true)
                ])
            }
            if let backCat = defaultCategories.first(where: { $0.name == "Back" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Deadlift", category: backCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Pull-Up", category: backCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Barbell Row", category: backCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Lat Pulldown", category: backCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Seated Cable Row", category: backCat, modality: .repetition, standard: true)
                ])
            }
            if let shouldersCat = defaultCategories.first(where: { $0.name == "Shoulders" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Overhead Press", category: shouldersCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Lateral Raise", category: shouldersCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Front Raise", category: shouldersCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Reverse Fly", category: shouldersCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Arnold Press", category: shouldersCat, modality: .repetition, standard: true)
                ])
            }
            if let bicepsCat = defaultCategories.first(where: { $0.name == "Biceps" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Bicep Curl", category: bicepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Hammer Curl", category: bicepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Preacher Curl", category: bicepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Concentration Curl", category: bicepsCat, modality: .repetition, standard: true)
                ])
            }
            if let tricepsCat = defaultCategories.first(where: { $0.name == "Triceps" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Tricep Pushdown", category: tricepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Skullcrusher", category: tricepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Overhead Tricep Extension", category: tricepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Tricep Dips", category: tricepsCat, modality: .repetition, standard: true)
                ])
            }
            if let forearmsCat = defaultCategories.first(where: { $0.name == "Forearms" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Wrist Curl", category: forearmsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Reverse Wrist Curl", category: forearmsCat, modality: .repetition, standard: true)
                ])
            }
            if let quadricepsCat = defaultCategories.first(where: { $0.name == "Quadriceps" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Squat", category: quadricepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Leg Press", category: quadricepsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Leg Extension", category: quadricepsCat, modality: .repetition, standard: true)
                ])
            }
            if let hamstringsCat = defaultCategories.first(where: { $0.name == "Hamstrings" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Hamstring Curl", category: hamstringsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Romanian Deadlift", category: hamstringsCat, modality: .repetition, standard: true)
                ])
            }
            if let glutesCat = defaultCategories.first(where: { $0.name == "Glutes" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Hip Thrust", category: glutesCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Glute Bridge", category: glutesCat, modality: .repetition, standard: true)
                ])
            }
            if let calvesCat = defaultCategories.first(where: { $0.name == "Calves" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Calf Raise", category: calvesCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Seated Calf Raise", category: calvesCat, modality: .repetition, standard: true)
                ])
            }
            if let abdominalsCat = defaultCategories.first(where: { $0.name == "Abdominals" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Plank", category: abdominalsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Crunch", category: abdominalsCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Leg Raise", category: abdominalsCat, modality: .repetition, standard: true)
                ])
            }
            if let obliquesCat = defaultCategories.first(where: { $0.name == "Obliques" }) {
                defaultExercises.append(contentsOf: [
                    ExerciseTemplate(name: "Russian Twist", category: obliquesCat, modality: .repetition, standard: true),
                    ExerciseTemplate(name: "Side Plank", category: obliquesCat, modality: .repetition, standard: true)
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
            
            // Big 5 Compound Routine
            let big5Exercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3)
            ]
            let big5Routine = Routine(name: "Big 5 Compound", exercises: big5Exercises, favorite: false)

            // Full-Body Strength
            let fullBodyStrengthExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3)
            ]
            let fullBodyStrengthRoutine = Routine(name: "Full-Body Strength", exercises: fullBodyStrengthExercises, favorite: false)

            // Push Day
            let pushDayExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Incline Dumbbell Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Tricep Pushdown"), setCount: 3)
            ]
            let pushDayRoutine = Routine(name: "Push Day", exercises: pushDayExercises, favorite: false)

            // Pull Day
            let pullDayExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Lat Pulldown"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Seated Cable Row"), setCount: 3)
            ]
            let pullDayRoutine = Routine(name: "Pull Day", exercises: pullDayExercises, favorite: false)

            // Leg Day
            let legDayExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Leg Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Leg Extension"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Calf Raise"), setCount: 3)
            ]
            let legDayRoutine = Routine(name: "Leg Day", exercises: legDayExercises, favorite: false)

            // Upper-Body Strength
            let upperBodyStrengthExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Bicep Curl"), setCount: 3)
            ]
            let upperBodyStrengthRoutine = Routine(name: "Upper-Body Strength", exercises: upperBodyStrengthExercises, favorite: false)

            // Lower-Body Strength
            let lowerBodyStrengthExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Romanian Deadlift"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Leg Extension"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Glute Bridge"), setCount: 3)
            ]
            let lowerBodyStrengthRoutine = Routine(name: "Lower-Body Strength", exercises: lowerBodyStrengthExercises, favorite: false)

            // Core & Stability
            let coreStabilityExercises: [ExerciseInRoutine] = [
                ExerciseInRoutine(exerciseTemplate: template(named: "Plank"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Crunch"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Russian Twist"), setCount: 3),
                ExerciseInRoutine(exerciseTemplate: template(named: "Side Plank"), setCount: 3)
            ]
            let coreStabilityRoutine = Routine(name: "Core & Stability", exercises: coreStabilityExercises, favorite: false)

            // Insert all new routines
            [
                big5Routine,
                fullBodyStrengthRoutine,
                pushDayRoutine,
                pullDayRoutine,
                legDayRoutine,
                upperBodyStrengthRoutine,
                lowerBodyStrengthRoutine,
                coreStabilityRoutine
            ].forEach { context.insert($0) }
        }
        
        // Save all changes in one transaction.
        try context.save()
        
    } catch {
        print("Error initializing default data: \(error.localizedDescription)")
    }
}
