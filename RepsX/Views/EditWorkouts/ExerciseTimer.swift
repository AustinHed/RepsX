//
//  ExerciseTimer.swift
//  RepsX
//
//  Created by Austin Hed on 3/3/25.
//

import SwiftUI

struct ExerciseTimer: View {
    // Total time is 90 seconds (1:30) as a Double for fractional updates
    private let totalTime: Double = 90.0
    @State private var remainingTime: Double = 90.0
    @State private var isRunning: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Timer publisher that ticks every 0.1 second for smoother animation.
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            // Start/Stop button
            Button(action: toggleTimer) {
                Text(isRunning ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.leading, 50)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.trailing, 50)
            }
        }
        // Timer and time circle
        .overlay(
            ZStack {
                // The progress circle using .trim to reflect the remaining time smoothly
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color.blue, lineWidth: 5)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)
                
                // The time string in MM:SS format
                Text(timeString)
                    .font(.headline)
            }
        )
        // Update the timer every 0.1 seconds for smoother progress
        .onReceive(timer) { _ in
            guard isRunning else { return }
            if remainingTime > 0 {
                withAnimation(.linear(duration: 0.1)) {
                    remainingTime -= 0.1
                }
            } else {
                withAnimation(.linear(duration: 0.1)) {
                    isRunning = false
                    remainingTime = totalTime
                }
            }
        }
    }
    
    // Toggle between running and stopping the timer.
    private func toggleTimer() {
        if isRunning {
            withAnimation(.linear(duration: 0.1)) {
                isRunning = false
                remainingTime = totalTime
            }
        } else {
            if remainingTime <= 0 {
                remainingTime = totalTime
            }
            isRunning = true
        }
    }
    
    // Compute the progress fraction for the circular indicator.
    private var progress: Double {
        remainingTime / totalTime
    }
    
    // Format the remaining time as MM:SS.
    private var timeString: String {
        let secondsInt = Int(remainingTime)
        let minutes = secondsInt / 60
        let seconds = secondsInt % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ExerciseTimer()
}
