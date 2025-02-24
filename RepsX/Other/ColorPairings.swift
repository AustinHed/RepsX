//
//  ColorPairings.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import Foundation
import SwiftUI

struct ColorPairing: Identifiable, Equatable {
    let id: String // use a unique name as the id
    let name: String
    let primary: Color
    let secondary: Color
    
    // A static list of available color pairings
    static let availablePairings: [ColorPairing] = [
        ColorPairing(id: "ocean", name: "Ocean", primary: .blue, secondary: .green),
        ColorPairing(id: "sunset", name: "Sunset", primary: .orange, secondary: .red),
        ColorPairing(id: "forest", name: "Forest", primary: .green, secondary: .brown),
        ColorPairing(id: "midnight", name: "Midnight", primary: .black, secondary: .purple)
    ]
}

struct GlobalKeyboardDoneButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                // This toolbar is placed in the keyboard area.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        // This sends a resignFirstResponder action, dismissing the keyboard.
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
    }
}

extension View {
    func globalKeyboardDoneButton() -> some View {
        self.modifier(GlobalKeyboardDoneButton())
    }
}
