//
//  RoutineGroup.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData
import Foundation

@Model
class RoutineGroup: Identifiable {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Routine.group)
    var routines: [Routine]

    init(id: UUID = UUID(), name: String, routines: [Routine] = []) {
        self.id = id
        self.name = name
        self.routines = routines
    }
}
