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

//#Preview {
//    ZStack {
//        Color.blue.opacity(0.2)
//            .edgesIgnoringSafeArea(.all)
//        WavyBackground(startPoint: 50,
//                       endPoint: 120,
//                       point1x: 0.6,
//                       point1y: 0.1,
//                       point2x: 0.4,
//                       point2y: 0.015,
//                       color: Color.blue.opacity(0.2)
//        )
//            .edgesIgnoringSafeArea(.all)
//        WavyBackground(startPoint: 120,
//                       endPoint: 50,
//                       point1x: 0.4,
//                       point1y: 0.01,
//                       point2x: 0.6,
//                       point2y: 0.25,
//                       color: Color.blue.opacity(0.2)
//        )
//            .edgesIgnoringSafeArea(.all)
//    }
//    
//}

//note: adjust between CustomBackground and CustomBackground2 to use static or animated
struct CustomBackground3: View {
    var themeColor: Color

    // Use @State to allow the parameters to change and animate
    @State private var firstStartPoint: CGFloat = 50
    @State private var firstEndPoint: CGFloat = 120
    @State private var firstPoint1x: CGFloat = 0.6
    @State private var firstPoint1y: CGFloat = 0.1
    @State private var firstPoint2x: CGFloat = 0.4
    @State private var firstPoint2y: CGFloat = 0.015

    @State private var secondStartPoint: CGFloat = 120
    @State private var secondEndPoint: CGFloat = 50
    @State private var secondPoint1x: CGFloat = 0.4
    @State private var secondPoint1y: CGFloat = 0.01
    @State private var secondPoint2x: CGFloat = 0.6
    @State private var secondPoint2y: CGFloat = 0.25

    var body: some View {
        ZStack {
            // Base background color layer
            themeColor.opacity(0.1)
                .ignoresSafeArea()
            
            // First wavy layer
            WavyBackground(
                startPoint: firstStartPoint,
                endPoint: firstEndPoint,
                point1x: firstPoint1x,
                point1y: firstPoint1y,
                point2x: firstPoint2x,
                point2y: firstPoint2y,
                color: themeColor.opacity(0.1)
            )
            .ignoresSafeArea()
            
            // Second wavy layer
            WavyBackground(
                startPoint: secondStartPoint,
                endPoint: secondEndPoint,
                point1x: secondPoint1x,
                point1y: secondPoint1y,
                point2x: secondPoint2x,
                point2y: secondPoint2y,
                color: themeColor.opacity(0.1)
            )
            .ignoresSafeArea()
        }
        .onAppear {
            firstStartPoint = CGFloat.random(in: 40...60)
            firstEndPoint = CGFloat.random(in: 110...130)
            firstPoint1x = CGFloat.random(in: 0.5...0.7)
            firstPoint1y = CGFloat.random(in: 0.0...0.02)
            firstPoint2x = CGFloat.random(in: 0.3...0.5)
            firstPoint2y = CGFloat.random(in: 0.2...0.3)
            
            secondStartPoint = CGFloat.random(in: 110...130)
            secondEndPoint = CGFloat.random(in: 40...60)
            secondPoint1x = CGFloat.random(in: 0.3...0.5)
            secondPoint1y = CGFloat.random(in: 0.0...0.02)
            secondPoint2x = CGFloat.random(in: 0.5...0.7)
            secondPoint2y = CGFloat.random(in: 0.2...0.3)
            
            
        }
    }
}

struct CustomBackground: View {
    var themeColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                themeColor.opacity(0.3),
                                themeColor.opacity(0.05)
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

//#Preview {
//    CustomBackground2(themeColor: .red)
//}
