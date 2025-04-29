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
    var lightModeHex: String
    var darkModeHex: String
    
    //whether this is the current theme
    var isSelected: Bool

    //init, which requires both colors
    init(id: UUID = UUID(),
         name: String,
         lightModeHex: String,
         darkModeHex: String,
         isSelected: Bool = false
    )
    {
        self.id = id
        self.name = name
        self.lightModeHex = lightModeHex
        self.darkModeHex = darkModeHex
        self.isSelected = isSelected
    }
}

//choose the right color based on light or dark mode
extension UserTheme {
    func color(for colorScheme: ColorScheme) -> Color {
        //Color(hexString: colorScheme == .dark ? darkModeHex : lightModeHex)
        Color(hexString: lightModeHex)
    }
}
