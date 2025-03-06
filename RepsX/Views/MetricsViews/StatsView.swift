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
struct StatsView: View {
    // Fetch workouts from SwiftData.
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    //variable lookback period
    @State var lookbackRange = 7
    
    //lookback period
    private var lookbackPeriod: Date {
        let calendar = Calendar.current
        // We want to include today, so we go back lookback - 1 days
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(lookbackRange-1), to: Date()) ?? Date())
    }
    
    // Filter workouts to only those within lookback
    private var recentWorkouts: [Workout] {
        workouts.filter { $0.startTime >= lookbackPeriod }
    }
    
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        NavigationStack {
            List {
                //last 7 day average
                Section{
                    rollingWorkoutDuration
                }
                
                Section {
                    categoryDistributionChart
                }
                
                Section {
                    setIntensityChart
                }
                
                
                Section("Specific Stats") {
                    NavigationLink("Exercise") {
                        //todo
                    }
                    NavigationLink("Category") {
                        //todo
                    }
                }
                
                Section("Overall Stats"){
                    NavigationLink("Workout Length") {
                        //todo
                    }
                    NavigationLink("Volume") {
                        //todo
                    }
                    NavigationLink("Total Sets") {
                        //todo
                    }
                    NavigationLink("Total Reps") {
                        //todo
                    }
                    NavigationLink("Set Intensity") {
                        //todo
                    }
                }
            }
            .navigationTitle("Stats")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("test")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(lookbackRange == 7 ? "14-day view" : "7-day view") {
                            withAnimation{
                                if lookbackRange == 7 {
                                    lookbackRange = 14
                                } else {
                                    lookbackRange = 7
                                }
                            }
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
            
        }
    }
}

//MARK: Rolling Workout Duration
extension StatsView {
    
    //Daily stats
    private var dailyStats: [(day: Date, totalTime: TimeInterval)] {
        let calendar = Calendar.current
        
        // Group the workouts by the start of their day.
        let grouped = Dictionary(grouping: recentWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        // Create an array for each day in the last X days—even if there is no workout for a day.
        let stats = (0..<lookbackRange).compactMap { offset -> (Date, TimeInterval) in
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
        guard !recentWorkouts.isEmpty else { return 0 }
        let totalTime = recentWorkouts.reduce(0) { $0 + $1.workoutLength }
        let avgSeconds = totalTime / TimeInterval(lookbackRange)
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
        let previousStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(lookbackRange * 2 - 1), to: Date()) ?? Date())
        let previousEnd = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -lookbackRange, to: Date()) ?? Date())
        
        // Filter workouts that occurred in the previous period.
        let previousWorkouts = workouts.filter {
            let day = calendar.startOfDay(for: $0.startTime)
            return day >= previousStart && day <= previousEnd
        }
        guard !previousWorkouts.isEmpty else { return 0 }
        
        let totalTime = previousWorkouts.reduce(0) { $0 + $1.workoutLength }
        let avgSeconds = totalTime / TimeInterval(lookbackRange)
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
            Text("\(lookbackRange) days, ")
                .bold()
                .foregroundColor(.blue) +
            Text("you averaged ") +
            Text("\(Int(averageWorkoutTime)) minutes")
                .bold()
                .foregroundColor(.blue) +
            Text(" of exercise per day. That's up ") +
            Text("\(periodPercentageDifference, specifier: "%.0f")%")
                .bold()
                .foregroundColor(.blue) +
            Text(" since last time")
        } else {
            return Text("Over the past ") +
            Text("\(lookbackRange) days, ")
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

//MARK: Pie Chart
extension StatsView {
    
    //Daily stats, returned as a tuple (name, count, percentage)
    private var overallCategoryDistribution: [(category: String, count: Int, percentage: Double)] {
        // Gather all exercises from the recent workouts.
        let exercises = recentWorkouts.flatMap { $0.exercises }
        var frequency: [String: Int] = [:]
        
        // Count each exercise’s category, if available.
        for exercise in exercises {
            if let categoryName = exercise.category?.name, !categoryName.isEmpty {
                frequency[categoryName, default: 0] += 1
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

//MARK: Intensity
extension StatsView {
    
    /// Computes the average set intensity per day over the lookback period.
    /// For each day, it collects intensity values from all sets (of every exercise in each workout).
    private var dailyIntensityStats: [(day: Date, averageIntensity: Double)] {
        let calendar = Calendar.current
        
        // Group workouts by the start of their day.
        let grouped = Dictionary(grouping: recentWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        // For each day in the lookback period, calculate the average intensity.
        let stats = (0..<lookbackRange).compactMap { offset -> (Date, Double) in
            // Determine the day.
            let day = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let startOfDay = calendar.startOfDay(for: day)
            
            // Gather all intensity values from sets within exercises in workouts for this day.
            let workoutsForDay = grouped[startOfDay] ?? []
            let intensities: [Int] = workoutsForDay.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    exercise.sets.compactMap { $0.intensity }
                }
            }
            
            // Compute the average intensity (or 0 if there are none).
            let average = intensities.isEmpty ? 0.0 : Double(intensities.reduce(0, +)) / Double(intensities.count)
            return (startOfDay, average)
        }
        // Sort the stats in ascending order by date.
        return stats.sorted(by: { $0.0 < $1.0 })
    }
    
    /// Returns the highest average intensity among all days.
    private var highestAverageIntensity: Double {
        dailyIntensityStats.map { $0.averageIntensity }.max() ?? 0
    }
    
    /// Returns the day that saw the highest average intensity.
    private var highestIntensityDay: Date? {
        dailyIntensityStats.max { $0.averageIntensity < $1.averageIntensity }?.day
    }
    
    private var highestIntensityValue: Double? {
        dailyIntensityStats.max { $0.averageIntensity < $1.averageIntensity }?.averageIntensity
    }
    
    private var highestIntensityValueFormatted: String {
        highestIntensityValue.map { String(format: "%.2f", $0) } ?? "N/A"
    }
    
    /// Formats the highest intensity day as "Mon, Mar 5th".
    private var highestIntensityDayFormatted: String {
        guard let day = highestIntensityDay else { return "N/A" }
        let weekday = day.formatted(.dateTime.weekday(.abbreviated))
        let month = day.formatted(.dateTime.month(.abbreviated))
        let dayNumber = Calendar.current.component(.day, from: day)
        return "\(weekday), \(month) \(dayNumber.ordinal)"
    }
    
    /// A bar chart showing the average set intensity per day.
    /// The day with the highest average intensity is rendered in dark blue,
    /// while the other days are shown in lighter blue.
    /// A header view for the intensity chart.
    private var setIntensityHeader: some View {
        return Text("Your most intense day was ")
                
        + Text("\(highestIntensityDayFormatted)")
            .bold()
            .foregroundColor(.blue)
        + Text(", with an average set intensity of ")
        + Text(highestIntensityValueFormatted)
            .bold()
            .foregroundColor(.blue)
        
    }
    
    /// A bar chart view showing the average set intensity per day.
    private var setIntensityBarChart: some View {
        Chart {
            ForEach(dailyIntensityStats, id: \.day) { stat in
                BarMark(
                    x: .value("Date", stat.day, unit: .day),
                    y: .value("Average Intensity", stat.averageIntensity)
                )
                .clipShape(Capsule())
                .foregroundStyle(
                    stat.averageIntensity == highestAverageIntensity ?
                    Color.blue : Color.blue.opacity(0.5)
                )
            }
        }
        .frame(height: 150)
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
    
    /// The combined view that displays the header and bar chart.
    var setIntensityChart: some View {
        VStack {
            setIntensityHeader
            setIntensityBarChart
        }
    }
}


#Preview {
    StatsView(selectedTab: .constant(.stats))
}


