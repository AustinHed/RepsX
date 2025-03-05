//
//  LogViewRow.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import SwiftUI

struct LogViewRow: View {
    var workout: Workout

    var body: some View {
        VStack(spacing: 0) {
            accentLine
            contentStack
        }
        .background(Color.white)
        .cornerRadius(10)
    }
}

extension LogViewRow {
    // Accent bar at the top
    private var accentLine: some View {
        Rectangle()
            .fill(Color(hexString: workout.color ?? ""))
            .frame(height: 7)
    }

    // Main content container
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            headerView
            Divider()
                .padding(.bottom,5)
                .padding(.top, 5)
            exerciseList
        }
        .padding()
    }

    // Header view containing the workout name and date/time info
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.name)
                .font(.headline)
            Text(dateText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                
        }
    }

    // Composes the formatted date with workout length (if applicable)
    private var dateText: String {
        let formattedDate = workout.startTime.formatted(
            Date.FormatStyle()
                .locale(.current)
                .month(.abbreviated)
                .day(.twoDigits)
                .year(.defaultDigits)
        )
        return formattedDate + (workout.workoutLength != 0 ? " • \(Int(workout.workoutLength/60)) min" : "")
    }

    // Exercise list view: For each exercise, display the sets count and name
    private var exerciseList: some View {
        ForEach(workout.exercises, id: \.self) { exercise in
            HStack {
                Text("\(exercise.sets.count) x")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(exercise.name)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    let testWorkout:Workout = Workout(id: UUID(), name: "Test Workout", startTime: Date(), endTime: nil, rating: 4, exercises: [], color: "#EB5545")
    LogViewRow(workout: testWorkout)
}
