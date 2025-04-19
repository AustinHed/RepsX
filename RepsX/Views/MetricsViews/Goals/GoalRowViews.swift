//
//  GoalRowViews.swift
//  RepsX
//
//  Created by Austin Hed on 4/19/25.
//
import SwiftUI
import SwiftData
import Foundation

struct RecurringGoalRowView: View {
    let goal: ConsistencyGoal

    // Fetch up-to-date workouts; SwiftData will remove deleted items automatically
    @Query(sort: \Workout.startTime, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext

    private var viewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }

    var body: some View {
        // Compute the current period and progress from fresh query results
        let currentPeriod = viewModel.currentPeriod(for: goal)
        let currentProgress = viewModel.progress(in: currentPeriod, for: goal, from: workouts)

        return VStack(alignment: .leading) {
            Text(goal.name)
                .font(.headline)
            HStack {
                Text(goal.goalTimeframe.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(currentProgress)) / \(Int(goal.goalTarget)) \(goal.goalMeasurement.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: currentProgress, total: goal.goalTarget)
                .progressViewStyle(.linear)
        }
        .padding(.vertical, 8)
    }
}

struct TargetGoalRowView: View {
    let goal: TargetGoal

    // Keep this list in sync and never hold onto deleted objects
    @Query(sort: \Workout.startTime, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext

    private var viewModel: TargetGoalViewModel {
        TargetGoalViewModel(modelContext: modelContext)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(goal.name)
                .font(.headline)

            HStack {
                Text("Started on \(goal.startDate, format: .dateTime.month(.wide).day().year())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.progressDescription(for: goal, from: workouts))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(
                value: viewModel.progress(for: goal, from: workouts),
                total: 1.0
            )
            .progressViewStyle(.linear)
        }
        .padding(.vertical, 8)
    }
}
