//
//  WavyBackground.swift
//  RepsX
//
//  Created by Austin Hed on 3/21/25.
//

import SwiftUI

struct CustomBackground: View {
    var primaryColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                primaryColor.opacity(0.3),
                                primaryColor.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
