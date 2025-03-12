//
//  ColorPairings.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import Foundation
import SwiftUI

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
