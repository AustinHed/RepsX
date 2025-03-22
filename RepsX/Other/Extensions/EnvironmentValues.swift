//
//  EnvironmentValues.swift
//  RepsX
//
//  Created by Austin Hed on 3/21/25.
//

import SwiftUI

private struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue  // A sensible default
}

//allows storage of a color in the environment
extension EnvironmentValues {
    var themeColor: Color {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }
}
