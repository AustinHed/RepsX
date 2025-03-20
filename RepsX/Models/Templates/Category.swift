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
    var standard: Bool
    
    //initialize the instance
    init(id: UUID = UUID(),
         name: String,
         standard: Bool = false //default to custom unless otherwise noted
         ///defaulting to custom so that I only need to specify standard in my initializer function
    ) {
        self.id = id
        self.name = name
        self.standard = standard
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


