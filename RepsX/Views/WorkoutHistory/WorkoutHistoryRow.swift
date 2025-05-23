//
//  LogViewRow.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import SwiftUI

struct WorkoutHistoryRow: View {
    var workout: Workout
    @State private var isExpanded: Bool = false  // Default is contracted

    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            contentStack
        }
        .background(Color("lightAndDarkBackgrounds"))
        .cornerRadius(10)
    }
}

extension WorkoutHistoryRow {
    
    // The main content container.
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 5) {
            headerView
            if isExpanded {
                Divider()
                    .padding(.vertical, 5)
                exerciseList
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding()
    }
    
    // Header view now includes a dedicated disclosure button to toggle expansion.
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(workout.name)
                    .font(.headline)
                Text(dateText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundColor(primaryColor)
            }
            .buttonStyle(.plain)
        }
    }
    
    // Formats the date and workout length.
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
    
    // Lists the exercises for this workout.
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
