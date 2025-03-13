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
            return "History: \(template.name)"
        case .category(let category):
            return "History: \(category.name)"
        case .length:
            return "Workout Length History"
        case .volume:
            return "Volume History"
        case .sets:
            return "Set History"
        case .reps:
            return "Rep History"
        case .intensity:
            return "Intensity History"
        }
    }
}
