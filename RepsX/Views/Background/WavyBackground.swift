//
//  WavyBackground.swift
//  RepsX
//
//  Created by Austin Hed on 3/21/25.
//

import SwiftUI

struct WavyBackground: View {
    //params
    ///Determines how "low" the wave will go. A larger value means it dips down further
    let startPoint: CGFloat
    let endPoint: CGFloat
    ///the horizontal mu
    let point1x: CGFloat //= 0.5
    let point1y: CGFloat //= 0.0
    let point2x: CGFloat //= 0.5
    let point2y: CGFloat //= 0.15
    let color: Color
    
    var body: some View {
        
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            Path { path in
                //starting point
                ///x is always 0 because it means the edge of the screen
                ///as y increases the line ends lower and lower on the screen
                path.move(to: CGPoint(x: 0, y: startPoint))
                
                
                // Draw a wave from left to right
                path.addCurve(
                    to: CGPoint(x: width, y: endPoint),
                    control1: CGPoint(x: width * point1x, y: height * point1y),
                    control2: CGPoint(x: width * point2x, y: height * point2y)
                )
                
                // Extend down the right edge
                path.addLine(to: CGPoint(x: width, y: height))
                // Extend across the bottom edge
                path.addLine(to: CGPoint(x: 0, y: height))
                // Close the shape
                path.closeSubpath()
            }
            // Fill the shape with a top-to-bottom gradient
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.01)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.2)
            .edgesIgnoringSafeArea(.all)
        WavyBackground(startPoint: 50,
                       endPoint: 120,
                       point1x: 0.6,
                       point1y: 0.1,
                       point2x: 0.4,
                       point2y: 0.015,
                       color: Color.blue.opacity(0.2)
        )
            .edgesIgnoringSafeArea(.all)
        WavyBackground(startPoint: 120,
                       endPoint: 50,
                       point1x: 0.4,
                       point1y: 0.01,
                       point2x: 0.6,
                       point2y: 0.25,
                       color: Color.blue.opacity(0.2)
        )
            .edgesIgnoringSafeArea(.all)
    }
    
}
