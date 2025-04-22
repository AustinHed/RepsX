//
//  ChartFilterEnum.swift
//  RepsX
//
//  Created by Austin Hed on 3/6/25.
//

enum ChartFilter {
    case exercise(ExerciseTemplate)
    case category(CategoryModel)
    case length
    case volume
    case sets
    case reps
    case intensity

    var navigationTitle: String {
        switch self {
        case .exercise(let template):
            return "\(template.name)"
        case .category(let category):
            return "\(category.name)"
        case .length:
            return "Workout Duration"
        case .volume:
            return "Workout Volume"
        case .sets:
            return "Total Sets"
        case .reps:
            return "Total Reps"
        case .intensity:
            return "Set Intensity"
        }
    }
}
