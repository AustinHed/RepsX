import SwiftUI
import Charts
import SwiftData

// Global constant: 7 days ago
private let sevenDaysAgo: Date = {
    Calendar.current.startOfDay(for: Date().addingTimeInterval(-7 * 24 * 60 * 60))
}()

struct ExerciseOverTimeChartView: View {
    let filter: ChartFilter
    let workouts: [Workout]  // Provided list of workouts
    // Lookback period: 7 days (in seconds)
    let timePeriod: TimeInterval = 7 * 24 * 60 * 60

    @State private var computedChartData: [ChartDataPoint] = []
    
    // Snapshot structs to capture only the properties we need.
    struct WorkoutSnapshot {
        let startTime: Date
        let exercises: [ExerciseSnapshot]
    }
    
    struct ExerciseSnapshot {
        let templateId: UUID
        let setsCount: Int
        let categoryId: UUID?
    }
    
    // Compute the chart data using the provided workouts.
    private func computeChartData() {
        // Calculate the cutoff on the main thread.
        let cutoffDate = Date().addingTimeInterval(-timePeriod)
        
        // Create snapshots from workouts within the lookback period.
        let workoutSnapshots: [WorkoutSnapshot] = workouts
            .filter { $0.startTime >= cutoffDate }
            .map { workout in
                let exerciseSnapshots = workout.exercises.map { exercise in
                    ExerciseSnapshot(
                        templateId: exercise.templateId,
                        setsCount: exercise.sets.count,
                        categoryId: exercise.category?.id
                    )
                }
                return WorkoutSnapshot(startTime: workout.startTime, exercises: exerciseSnapshots)
            }
        
        // Process the snapshots on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            
            // Group snapshots by the start of their day.
            let grouped = Dictionary(grouping: workoutSnapshots, by: { calendar.startOfDay(for: $0.startTime) })
            
            // Sum up the total sets for exercises that match the filter.
            let result: [ChartDataPoint] = grouped.map { (day, snapshots) in
                let totalSets = snapshots.reduce(0) { total, snapshot in
                    total + snapshot.exercises.reduce(0) { sum, ex in
                        switch filter {
                        case .exercise(let exerciseTemplate):
                            return ex.templateId == exerciseTemplate.id ? sum + ex.setsCount : sum
                        case .category(let category):
                            return ex.categoryId == category.id ? sum + ex.setsCount : sum
                        }
                    }
                }
                return ChartDataPoint(date: day, totalSets: totalSets)
            }
            .sorted { $0.date < $1.date }
            
            DispatchQueue.main.async {
                self.computedChartData = result
            }
        }
    }
    
    var body: some View {
        VStack {
            if computedChartData.isEmpty {
                Text("No data available for the selected period.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(computedChartData) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Total Sets", point.totalSets)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(filter.navigationTitle)
        .onAppear {
            computeChartData()
        }
        // If the provided workouts array changes, recompute the chart data.
        .onChange(of: workouts) { _ in
            computeChartData()
        }
    }
}
