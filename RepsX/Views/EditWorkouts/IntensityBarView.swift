//
//  IntensityBarView.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI

struct IntensityBar: View {
    // Accept a binding to a WorkoutSet instance
    @State var set: Set
    
    @Environment(\.modelContext) private var modelContext
    
    //set view model
    private var setViewModel:SetViewModel {
        SetViewModel(modelContext: modelContext)
    }

    private let gapWidth: CGFloat = 2

    var body: some View {
        HStack(spacing: gapWidth) {
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .foregroundColor(colorForSegment(at: index))
                    .onTapGesture {
                        // Update the intensity property based on the tapped segment (1-indexed)
                        withAnimation(.bouncy) {
                            setViewModel.updateIntensity(set, newIntensity: index + 1)
                        }
                        
                    }
            }
        }
        // The white background shows through as the gap lines between segments.
        .background(Color.white)
        .frame(height: 15)
        .cornerRadius(18)
    }

    // Determine the color for each segment based on the intensity value from workoutSet
    private func colorForSegment(at index: Int) -> Color {
        switch set.intensity {
        case nil:
            return Color.gray.opacity(0.5)
        case 1:
            // Only the first segment is red
            return index == 0 ? Color.green.opacity(0.2) : Color.gray.opacity(0.5)
        case 2:
            // The first two segments are green
            return index < 2 ? Color.green.opacity(0.4) : Color.gray.opacity(0.5)
        case 3:
            // All segments are blue
            return index < 3 ? Color.green.opacity(0.6) : Color.gray.opacity(0.5)
        case 4:
            return index < 4 ? Color.green.opacity(0.8) : Color.gray.opacity(0.5)
        case 5:
            return index < 5 ? Color.green.opacity(1.0) : Color.gray.opacity(1.5)
        default:
            return Color.gray.opacity(0.5)
        }
    }
}

#Preview {
    //default data
    let newWorkout = Workout(id: UUID(), startTime: Date())
    let newExercise = Exercise(name: "Bench Press", category: .chest, workout: newWorkout)
    let newSet = Set(exercise: newExercise, reps: 10, weight: 10, intensity: 3)
    
    @Environment(\.modelContext) var modelContext
    let setViewModel:SetViewModel = SetViewModel(modelContext: modelContext)
    IntensityBar(set:Set(exercise: newExercise, reps: 10, weight: 10, intensity: 3))
        .padding(.horizontal)
}
