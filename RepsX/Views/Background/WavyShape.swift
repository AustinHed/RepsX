//
//  WavyShape.swift
//  RepsX
//
//  Created by Austin Hed on 3/22/25.
//

import SwiftUI

// MARK: - Animatable Wavy Shape

struct WavyShape: Shape {
    var startPoint: CGFloat
    var endPoint: CGFloat
    var point1x: CGFloat
    var point1y: CGFloat
    var point2x: CGFloat
    var point2y: CGFloat
    
    // Combine all 6 values into one animatable data value using nested AnimatablePairs
    var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>
    > {
        get {
            AnimatablePair(
                AnimatablePair(startPoint, endPoint),
                AnimatablePair(
                    AnimatablePair(point1x, point1y),
                    AnimatablePair(point2x, point2y)
                )
            )
        }
        set {
            startPoint = newValue.first.first
            endPoint = newValue.first.second
            point1x = newValue.second.first.first
            point1y = newValue.second.first.second
            point2x = newValue.second.second.first
            point2y = newValue.second.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        // Starting point on the left edge
        path.move(to: CGPoint(x: 0, y: startPoint))
        
        // Draw a curve across the width
        path.addCurve(
            to: CGPoint(x: width, y: endPoint),
            control1: CGPoint(x: width * point1x, y: height * point1y),
            control2: CGPoint(x: width * point2x, y: height * point2y)
        )
        
        // Close out the shape at the bottom
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Animated Custom Background

struct CustomBackground: View {
    var themeColor: Color

    // Wave parameters for the first layer
    @State private var firstStartPoint: CGFloat = 50
    @State private var firstEndPoint: CGFloat = 120
    @State private var firstPoint1x: CGFloat = 0.6
    @State private var firstPoint1y: CGFloat = 0.1
    @State private var firstPoint2x: CGFloat = 0.4
    @State private var firstPoint2y: CGFloat = 0.015

    // Wave parameters for the second layer
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
            
            // First wavy layer using the animatable shape
            WavyShape(
                startPoint: firstStartPoint,
                endPoint: firstEndPoint,
                point1x: firstPoint1x,
                point1y: firstPoint1y,
                point2x: firstPoint2x,
                point2y: firstPoint2y
            )
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [themeColor.opacity(0.1), themeColor.opacity(0.01)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            
            // Second wavy layer using the animatable shape
            WavyShape(
                startPoint: secondStartPoint,
                endPoint: secondEndPoint,
                point1x: secondPoint1x,
                point1y: secondPoint1y,
                point2x: secondPoint2x,
                point2y: secondPoint2y
            )
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [themeColor.opacity(0.1), themeColor.opacity(0.01)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
        }
        .onAppear {
            // Set up a timer to update the parameters every 10 seconds
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                withAnimation(Animation.linear(duration: 10)) {
                    // Randomize parameters for the first wave layer
                    firstStartPoint = CGFloat.random(in: 40...60)
                    firstEndPoint   = CGFloat.random(in: 110...130)
                    firstPoint1x    = CGFloat.random(in: 0.5...0.7)
                    firstPoint1y    = CGFloat.random(in: 0.0...0.02)
                    firstPoint2x    = CGFloat.random(in: 0.3...0.5)
                    firstPoint2y    = CGFloat.random(in: 0.2...0.3)
                    
                    // Randomize parameters for the second wave layer
                    secondStartPoint = CGFloat.random(in: 110...130)
                    secondEndPoint   = CGFloat.random(in: 40...60)
                    secondPoint1x    = CGFloat.random(in: 0.3...0.5)
                    secondPoint1y    = CGFloat.random(in: 0.0...0.02)
                    secondPoint2x    = CGFloat.random(in: 0.5...0.7)
                    secondPoint2y    = CGFloat.random(in: 0.2...0.3)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CustomBackground(themeColor: .red)
}
