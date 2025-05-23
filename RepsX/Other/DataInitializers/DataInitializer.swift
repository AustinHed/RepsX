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

            // Create default Routine Groups
            let pushGroup = RoutineGroup(name: "Push")
            let pullGroup = RoutineGroup(name: "Pull")
            let legsGroup = RoutineGroup(name: "Legs")
            let fullBodyGroup = RoutineGroup(name: "Full Body")
            [pushGroup, pullGroup, legsGroup, fullBodyGroup].forEach { context.insert($0) }

            // --- Push Group Routines ---
            let pushRoutine1 = Routine(
                name: "Push Volume",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Incline Dumbbell Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Lateral Raise"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Tricep Pushdown"), setCount: 3)
                ],
                group: pushGroup
            )
            let pushRoutine2 = Routine(
                name: "Chest & Shoulders",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Decline Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Arnold Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Front Raise"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Skullcrusher"), setCount: 3)
                ],
                group: pushGroup
            )
            let pushRoutine3 = Routine(
                name: "Triceps Focus",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Tricep Extension"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Tricep Dips"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Incline Dumbbell Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Cable Fly"), setCount: 3)
                ],
                group: pushGroup
            )

            // --- Pull Group Routines ---
            let pullRoutine1 = Routine(
                name: "Pull Strength",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Hammer Curl"), setCount: 3)
                ],
                group: pullGroup
            )
            let pullRoutine2 = Routine(
                name: "Back & Biceps",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Lat Pulldown"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Seated Cable Row"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bicep Curl"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Reverse Fly"), setCount: 3)
                ],
                group: pullGroup
            )
            let pullRoutine3 = Routine(
                name: "Row Emphasis",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Preacher Curl"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Concentration Curl"), setCount: 3)
                ],
                group: pullGroup
            )

            // --- Legs Group Routines ---
            let legsRoutine1 = Routine(
                name: "Quad Dominant",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Leg Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Leg Extension"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Calf Raise"), setCount: 3)
                ],
                group: legsGroup
            )
            let legsRoutine2 = Routine(
                name: "Hamstring Builder",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Romanian Deadlift"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Hamstring Curl"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Glute Bridge"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Seated Calf Raise"), setCount: 3)
                ],
                group: legsGroup
            )
            let legsRoutine3 = Routine(
                name: "Glute Focus",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Hip Thrust"), setCount: 4),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Leg Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Glute Bridge"), setCount: 3)
                ],
                group: legsGroup
            )

            // --- Full Body Group Routines ---
            let fullBodyRoutine1 = Routine(
                name: "Full Body Power",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Deadlift"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Pull-Up"), setCount: 3)
                ],
                group: fullBodyGroup
            )
            let fullBodyRoutine2 = Routine(
                name: "Full Body Classic",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Lat Pulldown"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Leg Extension"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Hamstring Curl"), setCount: 3)
                ],
                group: fullBodyGroup
            )
            let fullBodyRoutine3 = Routine(
                name: "Full Body Express",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 2),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Barbell Row"), setCount: 2),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 2),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Plank"), setCount: 2)
                ],
                group: fullBodyGroup
            )

            // --- Ungrouped Routines ---
            let ungroupedRoutine1 = Routine(
                name: "Upper Burn",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bench Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Overhead Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Bicep Curl"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Tricep Dips"), setCount: 3)
                ],
                group: nil
            )
            let ungroupedRoutine2 = Routine(
                name: "Lower Burn",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Squat"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Leg Press"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Romanian Deadlift"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Calf Raise"), setCount: 3)
                ],
                group: nil
            )
            let ungroupedRoutine3 = Routine(
                name: "Core & Stability",
                exercises: [
                    ExerciseInRoutine(exerciseTemplate: template(named: "Plank"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Crunch"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Russian Twist"), setCount: 3),
                    ExerciseInRoutine(exerciseTemplate: template(named: "Side Plank"), setCount: 3)
                ],
                group: nil
            )

            // Insert all new routines
            [
                pushRoutine1, pushRoutine2, pushRoutine3,
                pullRoutine1, pullRoutine2, pullRoutine3,
                legsRoutine1, legsRoutine2, legsRoutine3,
                fullBodyRoutine1, fullBodyRoutine2, fullBodyRoutine3,
                ungroupedRoutine1, ungroupedRoutine2, ungroupedRoutine3
            ].forEach { context.insert($0) }
        }
        
        // Save all changes in one transaction.
        try context.save()
        
    } catch {
        print("Error initializing default data: \(error.localizedDescription)")
    }
}
