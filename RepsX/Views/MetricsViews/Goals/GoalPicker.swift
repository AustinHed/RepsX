import SwiftUI
import SwiftData

struct CustomGoalPicker<T>: View where T: RawRepresentable, T: CaseIterable, T: Equatable, T: Hashable, T.RawValue == String {
    
    @Environment(\.themeColor) var themeColor
    @Binding var selection: T
    // for the custom picker animation
    @Namespace private var pickerAnimation
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundStyle(Color.white.opacity(0.1))
            
            HStack(spacing: 0) {
                // Wrap the cases in Array to ensure RandomAccessCollection conformance
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button {
                        withAnimation(.bouncy) {
                            selection = option
                        }
                    } label: {
                        customPickerItem(title: option.rawValue, isActive: selection == option)
                    }
                }
            }
            .padding(5)
        }
    }
    
    // Animation and selected foreground
    func customPickerItem(title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(isActive ? .black : .gray)
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Only add the background for the active option.
                    if isActive {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(themeColor.opacity(0.3))
                            // Use matchedGeometryEffect with a shared id.
                            .matchedGeometryEffect(id: "pickerBackground", in: pickerAnimation)
                    }
                }
            )
            .cornerRadius(30)
    }
}

#Preview {
    // Preview example with GoalMeasurement
    @Previewable @State var selectedMeasurement: GoalMeasurement = .minutes
    ScrollView {
        LazyVStack {
            VStack {
                Text("Custom text")
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.white)
                    // Specify the generic type explicitly
                    CustomGoalPicker<GoalMeasurement>(selection: $selectedMeasurement)
                        .padding()
                }
                .padding(.horizontal)
            }
        }
    }
    .background(Color.gray.opacity(0.2))
}
