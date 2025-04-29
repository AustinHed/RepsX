//
//  EnvironmentValues.swift
//  RepsX
//
//  Created by Austin Hed on 3/21/25.
//

import SwiftUI

//MARK: Newer
struct ThemeModelKey: EnvironmentKey {
    static let defaultValue = UserTheme(
        name: "Default",
        lightModeHex: "#FF5733",
        darkModeHex: "#C0392B"
    )
}
extension EnvironmentValues {
    var themeModel: UserTheme {
        get { self[ThemeModelKey.self] }
        set { self[ThemeModelKey.self] = newValue }
    }
}
