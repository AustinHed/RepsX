//
//  SetViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/17/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class SetViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addSet(to exercise: Exercise, reps: Int, weight: Double) {
        let newSet = Set(id: UUID(), reps: reps, weight: weight, exercise: exercise)
        exercise.sets.append(newSet)
        modelContext.insert(newSet)
    }

    func deleteSet(_ set: Set, from exercise: Exercise) {
            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                exercise.sets.remove(at: index)
            }
            modelContext.delete(set)
        }

    func fetchSets(for exercise: Exercise) -> [Set] {
            return exercise.sets
        }
}
