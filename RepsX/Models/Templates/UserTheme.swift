//
//  UserTheme.swift
//  RepsX
//
//  Created by Austin Hed on 3/4/25.
//

import SwiftData
import SwiftUI

@Model
final class UserTheme {
    
    //standard variables
    var id: UUID
    var name: String
    
    //the two colors for a given theme
    var primaryHex: String
    var secondaryHex: String
    
    //whether this is the current theme
    var isSelected: Bool

    //init, which requires both colors
    init(id: UUID = UUID(),
         name: String,
         primaryHex: String,
         secondaryHex: String,
         isSelected: Bool = false
    )
    {
        self.id = id
        self.name = name
        self.primaryHex = primaryHex
        self.secondaryHex = secondaryHex
        self.isSelected = isSelected
    }
}
