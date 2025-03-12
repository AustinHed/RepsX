//
//  ChartFilterEnum.swift
//  RepsX
//
//  Created by Austin Hed on 3/6/25.
//

enum ChartFilter {
    case exercise(ExerciseTemplate)
    case category(CategoryModel)
    
    var navigationTitle: String {
        switch self {
        case .exercise(let template):
            return "History: \(template.name)"
        case .category(let category):
            return "History: \(category.name)"
        }
    }
}
