//
//  StatsView.swift
//  RepsX
//
//  Created by Austin Hed on 3/5/25.
//

import SwiftUI
import Charts
import SwiftData

// Example StatsView
struct StatsHomeView: View {
    // Fetch workouts from SwiftData for hte L14 days
    @Query(filter: Workout.currentPredicate(),
           sort: \Workout.startTime) var workouts: [Workout]
    
    //fetch all exercises for the L14D
    @Query(filter: Exercise.currentPredicate()
    ) var exercisesList: [Exercise]
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        NavigationStack {
            List {
                //duration
                Section("Highlights"){
                    
                rollingWorkoutDuration
                }
                //category
                Section {
                    Text("hiding category chart")
                    categoryDistributionChart
                }
                
                Section("Specific Stats") {
                    
                    NavigationLink("Exercise") {
                        ListOfExerciseTemplatesView(navigationTitle: "Select an Exercise", allWorkouts: workouts) { exercise in
                            ExerciseAndCategoryChartsView(filter: .exercise(exercise), workouts: workouts)
                        }
                    }
                    
                    NavigationLink("Category") {
                        ListOfCategoriesView(navigationTitle:"Select a Category", allWorkouts: workouts) {
                            category in
                            ExerciseAndCategoryChartsView(filter: .category(category), workouts: workouts)
                        }
                    }
                }
                
                Section("Overall Stats"){
                    //favorite exercises
                    //favorite categories
                    NavigationLink("Workout Duration") {
                        GeneralChartsView(filter: .length, workouts: workouts)
                    }
                    NavigationLink("Workout Volume") {
                        GeneralChartsView(filter: .volume, workouts: workouts)
                    }
                    NavigationLink("Total Sets") {
                        GeneralChartsView(filter: .sets, workouts: workouts)
                    }
                    NavigationLink("Total Reps") {
                        GeneralChartsView(filter: .reps, workouts: workouts)
                    }
                    NavigationLink("Set Intensity") {
                        GeneralChartsView(filter: .intensity, workouts: workouts)
                    }
                }
            }
            .navigationTitle("Stats")
            .listSectionSpacing(12)
        }
    }
}


//MARK: Duration Bar Chart
extension StatsHomeView {
    
    //Daily stats
    private var dailyStats: [(day: Date, totalTime: TimeInterval)] {
        let calendar = Calendar.current
        
        // Group the workouts by the start of their day.
        let grouped = Dictionary(grouping: workouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        // Create an array for each day in the last X days—even if there is no workout for a day.
        let stats = (0..<14).compactMap { offset -> (Date, TimeInterval) in
            // Generate each day from today going back lookbackRange days.
            let day = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let startOfDay = calendar.startOfDay(for: day)
            // Sum the total workout length for this day (in seconds).
            let totalTime = grouped[startOfDay]?.reduce(0, { $0 + $1.workoutLength }) ?? 0
            return (startOfDay, totalTime)
        }
        // Sort the days in ascending order (oldest on the left, today on the right).
        return stats.sorted(by: { $0.0 < $1.0 })
    }
    
    //Average time calculation
    private var averageWorkoutTime: TimeInterval {
        guard !workouts.isEmpty else { return 0 }
        let totalTime = workouts.reduce(0) { $0 + $1.workoutLength }
        let avgSeconds = totalTime / TimeInterval(14)
        return avgSeconds / 60
    }
    
    // Average workout time (in minutes) for the previous period.
    // The previous period is defined as the lookbackRange days immediately before the current period.
    private var previousPeriodAverageWorkoutTime: TimeInterval {
        let calendar = Calendar.current
        
        // Define the start of the previous period.
        // For example, if lookbackRange is 7:
        // - Current period: today through 6 days ago.
        // - Previous period: 7 days ago through 13 days ago.
        let previousStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(14 * 2 - 1), to: Date()) ?? Date())
        let previousEnd = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date())
        
        // Filter workouts that occurred in the previous period.
        let previousWorkouts = workouts.filter {
            let day = calendar.startOfDay(for: $0.startTime)
            return day >= previousStart && day <= previousEnd
        }
        guard !previousWorkouts.isEmpty else { return 0 }
        
        let totalTime = previousWorkouts.reduce(0) { $0 + $1.workoutLength }
        let avgSeconds = totalTime / TimeInterval(14)
        return avgSeconds / 60
    }
    
    // Percentage difference between the current period's average and the previous period's average.
    // Calculated as: ((current - previous) / previous) * 100
    private var periodPercentageDifference: Double {
        let currentAvg = averageWorkoutTime
        let previousAvg = previousPeriodAverageWorkoutTime
        guard previousAvg != 0 else { return 0 }
        return ((currentAvg - previousAvg) / previousAvg) * 100
    }
    
    //Header Text
    private var workoutDurationHeader: Text {
        if periodPercentageDifference != 0 {
            return Text("Over the past ") +
            Text("\(14) days, ")
                .bold()
                .foregroundColor(.blue) +
            Text("you averaged ") +
            Text("\(Int(averageWorkoutTime)) minutes")
                .bold()
                .foregroundColor(.blue) +
            Text(" of exercise per day. That's a ") +
            Text("\(periodPercentageDifference, specifier: "%.0f")%")
                .bold()
                .foregroundColor(.blue) +
            Text(" change vs the previous 14 day period")
        } else {
            return Text("Over the past ") +
            Text("\(14) days, ")
                .bold()
                .foregroundColor(.blue) +
            Text("you averaged ") +
            Text("\(Int(averageWorkoutTime)) minutes")
                .bold()
                .foregroundColor(.blue) +
            Text(" of exercise per day.")
        }
    }
    
    //Bar Chart
    private var workoutDurationChart: some View {
        Chart {
            ForEach(dailyStats, id: \.day) { stat in
                BarMark(
                    x: .value("Date", stat.day, unit: .day),
                    y: .value("Workout Time (mins)", stat.totalTime / 60)
                )
                .clipShape(Capsule())  // Gives the bars a pill-like appearance.
            }
        }
        .padding(.vertical)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { value in
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(dateValue, format: .dateTime.month(.twoDigits).day(.twoDigits))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
    }
    
    //Header + Chart
    var rollingWorkoutDuration: some View {
        VStack {
            workoutDurationHeader
                .padding(.top)
            workoutDurationChart
        }
    }
}

//MARK: Category Pie Chart
extension StatsHomeView {
    
    //Daily stats, returned as a tuple (name, count, percentage)
    private var overallCategoryDistribution: [(category: String, count: Int, percentage: Double)] {
        
        // Gather all exercises from the recent workouts.
        let exercises = exercisesList
        
        // Build a frequency dictionary.
        var frequency: [String: Int] = [:]
        
        for exercise in exercises {
            //only look at non-hidden categories
            if exercise.category?.isHidden != true {
                if let categoryName = exercise.category?.name, !categoryName.isEmpty {
                    frequency[categoryName, default: 0] += 1
                }
            }
            
        }
        
        let total = frequency.values.reduce(0, +)
        return frequency.map { (category: $0.key,
                                 count: $0.value,
                                 percentage: total > 0 ? (Double($0.value) / Double(total) * 100) : 0) }
    }
    
    //most common category count
    private var mostCommonCount: Int {
        overallCategoryDistribution.map { $0.count }.max() ?? 0
    }
    //most common category name
    private var mostCommonCategoryName: String? {
        overallCategoryDistribution.max { $0.count < $1.count }?.category
    }
    //most common category percentage
    private var mostCommonCategoryPercentage: Double? {
        overallCategoryDistribution.max { $0.count < $1.count }?.percentage
    }
    
    //header text
    private var headerText: Text {
        let commonCategoryName = mostCommonCategoryName ?? "no category"
        let commonCategoryPercentage = mostCommonCategoryPercentage.map { String(format: "%.0f", $0) } ?? "0"
        
        return Text("\(commonCategoryName) ")
            .bold()
            .foregroundColor(.blue)
        + Text("was your favorite category, making up ")
        + Text("\(commonCategoryPercentage)%")
            .bold()
            .foregroundColor(.blue)
        + Text(" exercises logged")
    }
    
    //Pie Chart
    private var chartView: some View {
        Chart {
            ForEach(overallCategoryDistribution, id: \.category) { entry in
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .cornerRadius(5)
                .foregroundStyle(entry.count == mostCommonCount ? Color.blue : Color.blue.opacity(0.5))
            }
        }
        .frame(height: 100)
        .chartLegend(.visible)
    }
    
    //Header + Chart
    var categoryDistributionChart: some View {
        HStack {
            headerText
            chartView
        }
    }
}

extension Workout {
    static func currentPredicate() -> Predicate<Workout> {
        let currentDate = Date.now
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: currentDate)!
        
        return #Predicate<Workout> { workout in
            workout.startTime > fourteenDaysAgo
        }
    }
}

extension Exercise {
    static func currentPredicate() -> Predicate<Exercise> {
        let currentDate = Date.now
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: currentDate)!
        
        return #Predicate<Exercise> { exercise in
            //if the exercise does not have a parent workout, just give it a date that will ensure it doesn't show up
            exercise.workout?.startTime ?? fourteenDaysAgo > fourteenDaysAgo &&
            //exercise must have a category associated
                exercise.category != nil
        }
    }
}


