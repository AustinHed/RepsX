//
//  EditCustomThemeView.swift
//  RepsX
//
//  Created by Austin Hed on 4/29/25.
//
import SwiftUI
import SwiftData

struct EditCustomThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let customTheme: UserTheme

    @State private var selectedColor: Color

    init(customTheme: UserTheme) {
        self.customTheme = customTheme
        _selectedColor = State(initialValue: Color(hexString: customTheme.lightModeHex))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select Primary Color")
                    .font(.headline)

                ColorPicker("Color", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(height: 200)
            }
            .padding()
            .navigationTitle("Edit Custom Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTheme()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTheme() {
        customTheme.lightModeHex = selectedColor.toHex() ?? customTheme.lightModeHex
        customTheme.darkModeHex = selectedColor.darkerVariantHex() ?? customTheme.darkModeHex
        try? modelContext.save()
    }
}

#Preview {
    let testTheme: UserTheme = UserTheme(name: "Custom Theme", lightModeHex: "#5D6D7E", darkModeHex: "#283747")
    NavigationStack{
        EditCustomThemeView(customTheme: testTheme)
            .navigationTitle("Edit Custom Theme")
            .navigationBarTitleDisplayMode(.inline)
    }
    
}


