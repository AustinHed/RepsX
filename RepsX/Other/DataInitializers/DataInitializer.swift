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
            let categoryDefinitions = loadStandardCategories()
            defaultCategories = categoryDefinitions.map {
                let model = CategoryModel(id: $0.id, name: $0.name, standard: true)
                context.insert(model)
                return model
            }
        } else {
            defaultCategories = existingCategories
        }
        
        // MARK: - Exercise Templates
        
        // Fetch existing predefined exercises.
        let exerciseDescriptor = FetchDescriptor<ExerciseTemplate>()
        let existingExercises = try context.fetch(exerciseDescriptor)
        
        var allExerciseTemplates: [ExerciseTemplate] = []
        if existingExercises.isEmpty {
            let standardDefinitions = loadStandardExercises()
            var createdTemplates: [ExerciseTemplate] = []

            for def in standardDefinitions {
                // Find the CategoryModel that matches the decoded category name
                guard let category = defaultCategories.first(where: { $0.name == def.category }) else {
                    print("Missing category for exercise: \(def.name)")
                    continue
                }

                let template = ExerciseTemplate(
                    id: def.id,
                    name: def.name,
                    category: category,
                    modality: .repetition, //TODO: do more than just weights (cardio)
                    standard: true
                )

                context.insert(template)
                createdTemplates.append(template)
            }

            allExerciseTemplates = createdTemplates
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
