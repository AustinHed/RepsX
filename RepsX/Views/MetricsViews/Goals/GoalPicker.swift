import SwiftUI
import SwiftData
/// A segmented‐control style picker for _any_ CaseIterable+Hashable enum.
/// You supply a closure to get the display string for each case.
struct EnumPicker<T>: View
where
  T: CaseIterable & Hashable,
  T.AllCases: RandomAccessCollection
{
  @Binding var selection: T
  @Environment(\.themeColor) var themeColor
  @Namespace private var pickerAnimation

  /// Called for each case to get the String to display.
  let label: (T) -> String

  var body: some View {
    ZStack {
      Capsule().foregroundStyle(Color.white.opacity(0.1))
      HStack(spacing: 0) {
        ForEach(Array(T.allCases), id: \.self) { option in
          Button {
            withAnimation(.bouncy) {
              selection = option
            }
          } label: {
            Text(label(option))
              .font(.subheadline)
              .foregroundStyle(selection == option ? .black : .gray)
              .frame(height: 30)
              .frame(maxWidth: .infinity)
              .background(
                ZStack {
                  if selection == option {
                    RoundedRectangle(cornerRadius: 30)
                      .fill(themeColor.opacity(0.3))
                      .matchedGeometryEffect(id: "pickerBG", in: pickerAnimation)
                  }
                }
              )
              .cornerRadius(30)
          }
        }
      }
      .padding(5)
    }
  }
}
