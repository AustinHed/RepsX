import SwiftUI

//TODO: REMOVE
struct ColorPickerGrid: View {
    @Environment(\.dismiss) private var dismiss

    // Example color palette (adjust hex codes to match your desired colors)
    private let colors: [String] = [
        "#4AA9F0", // Blue
        "#59C76C", // Green
        "#A67C52", // Brown
        "#E66BBF", // Pink
        "#3EC5BA", // Teal
        "#946CD6", // Purple
        "#EB5545", // Red
        "#F99D2C", // Orange
        "#FBD24E",  // Yellow
        "#808080" // gray
    ]

    // Track the currently selected color (default to first color or anything you prefer)
    @State var selectedColor: String

    // Closure to call when a color is chosen
    var onColorSelected: (String) -> Void

    var body: some View {
        ZStack {
            // Dark, rounded background
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .frame(height: 140) // Enough height for two rows of circles

            HStack(spacing: 16) {
                // Large rectangle showing the currently selected color
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hexString: selectedColor))
                    //.fill(Color(UIColor(hex: selectedColor) ?? .gray))
                    .frame(width: 80, height: 80)
                    .padding(.leading, 16)


                // Two rows of color circles
                VStack(spacing: 12) {
                    // First row (5 colors)
                    HStack(spacing: 12) {
                        ForEach(colors[0..<5], id: \.self) { hex in
                            colorButton(hex: hex)
                        }
                    }
                    // Second row (remaining 4 colors)
                    HStack(spacing: 12) {
                        ForEach(colors[5..<10], id: \.self) { hex in
                            colorButton(hex: hex)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    /// A helper that builds each color circle button
    private func colorButton(hex: String) -> some View {
        Button {
            onColorSelected(hex)
            selectedColor = hex
            dismiss()
        } label: {
            Circle()
                //.fill(Color(UIColor(hex: hex) ?? .gray))
                .fill(Color(hexString: hex))
                .frame(width: 35, height: 35)
                // Outline the circle if it’s the currently selected color
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: selectedColor == hex ? 3 : 0)
                )
        }
    }
}

struct ColorPickerGrid_Previews: PreviewProvider {
    static var previews: some View {
        let selectedColor:String = "#808080"
        ZStack{
            Color.gray
            ColorPickerGrid(selectedColor: selectedColor) { chosenHex in
                print("Selected color: \(chosenHex)")
            }
        }
        
    }
}
