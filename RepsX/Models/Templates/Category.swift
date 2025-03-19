//
//  Category.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.
//

import SwiftData
import Foundation
import SwiftUI

@Model
class CategoryModel: Hashable {
    
    //standard variables
    var id: UUID
    var name: String
    
    //initialize the instance
    init(id: UUID = UUID(),
         name: String
    ) {
        self.id = id
        self.name = name
    }
    
    // Equatable conformance to support comparisons in views (if needed)
    func isEqual(lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
}


