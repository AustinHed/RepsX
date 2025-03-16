import SwiftUI
import Charts
import SwiftData

struct ExerciseAndCategoryChartsView: View {
    
    // Used to show either Exercise or Category data based on the filter provided.
    // Also updates the navigation title.
    let filter: ChartFilter
    
    // Passed in list of all workouts
    let workouts: [Workout]
    
    // Store the selected lookback option.
    @State private var selectedLookback: LookbackOption = .thirty
    
    // Compute the lookback period. If "All Time" is selected, return nil.
    private var lookbackPeriod: Date? {
        if selectedLookback == .all {
            return nil
        } else {
            let calendar = Calendar.current
            // For example, if 7 days is selected, we want workouts from today through 6 days ago.
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(selectedLookback.rawValue - 1), to: Date()) ?? Date())
        }
    }
    
    //the exerciseTemplateId for use in the button
    private var exerciseTemplate: ExerciseTemplate? {
        if case .exercise(let template) = filter {
            return template
        }
        return nil
    }
    
    
    //Dot and bar size
    let markerSize: CGFloat = 8
    
    var body: some View {
        if setChartData.isEmpty {
            Text("No data available for the selected period.")
                .foregroundStyle(.secondary)
        } else {
            
            ScrollView{
                LazyVStack(spacing:12) {
                    
                    //picker
                    Picker("Lookback", selection: $selectedLookback) {
                        ForEach(LookbackOption.allCases) { option in
                            Text(option.description).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    //metrics
                    StatsSummaryView(dataPoints: medianChartData, minDataPoints:minChartData, maxDataPoints:maxChartData, filter: filter, lookback: selectedLookback)
                    
                    //charts
                    ExpandableChartView(title: "Weight") {
                        medianWeightChart
                    }

                    ExpandableChartView(title:"Sets") {
                        setCountChart
                    }
                    
                    ExpandableChartView(title:"Volume") {
                        volumeCountChart
                    }
                                        
                    //button
                    if let template = exerciseTemplate {
                        exerciseHistoryNavigationLink(workouts: workouts, exerciseTemplate: template)
                    }
                }
                .navigationTitle(filter.navigationTitle)
                
            }
            .background(Color(UIColor.systemGroupedBackground))

        }
    }
    
    
}
//MARK: Workout History Button
extension ExerciseAndCategoryChartsView {
    func exerciseHistoryNavigationLink(workouts: [Workout], exerciseTemplate: ExerciseTemplate) -> some View {
        NavigationLink {
            ExerciseHistoryView(workouts: workouts, exerciseTemplate: exerciseTemplate)
        } label: {
            HStack {
                Text("Exercise History")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
    }
}

//MARK: X Axis Labels
extension ExerciseAndCategoryChartsView {
    // Calculate the stride based on the range of dates in chartData.
    private var xAxisStride: Int {
        guard let firstDate = setChartData.first?.date,
              let lastDate = setChartData.last?.date else { return 1 }
        let totalDays = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        // Target about 6 markers (you can adjust this value as needed)
        let targetTicks = 5
        return max(1, totalDays / targetTicks)
    }
}

//MARK: data aggregator function
extension ExerciseAndCategoryChartsView {
    // A helper function to aggregate data by day.
    private func aggregateData(using aggregator: ([Workout]) -> Double?) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            if selectedLookback == .all {
                return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
            } else {
                return lookbackPeriod ?? endDate
            }
        }()
        
        // Filter workouts within the full date range.
        let filteredWorkouts = workouts.filter { workout in
            let workoutDay = calendar.startOfDay(for: workout.startTime)
            return workoutDay >= startDate && workoutDay <= endDate
        }
        
        // Group workouts by the start of their day.
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            // Get the workouts for the current day.
            let workoutsForDay = grouped[currentDate] ?? []
            // Use the aggregator closure to compute the metric.
            if let value = aggregator(workoutsForDay) {
                points.append(ChartDataPoint(date: currentDate, value: value))
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return points.sorted { $0.date < $1.date }
    }
}

//MARK: Sets over time
extension ExerciseAndCategoryChartsView {
    
    // Computed property that aggregates chart data across the full selected date range.
    private var setChartData: [ChartDataPoint] {
        aggregateData { (workoutsForDay: [Workout]) -> Double? in
            guard !workoutsForDay.isEmpty else { return nil }
            return Double(workoutsForDay.reduce(0) { total, workout in
                total + workout.exercises.reduce(0) { sum, exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        return exercise.templateId == exerciseTemplate.id ? sum + exercise.sets.count : sum
                    case .category(let category):
                        return exercise.category?.id == category.id ? sum + exercise.sets.count : sum
                    default: //default is category
                        return sum
                    }
                }
            })
        }
    }
    
    //the chart
    private var setCountChart: some View {
        Chart(setChartData) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Total Sets", point.value)
            )
            .clipShape(Capsule())
        }
        .padding(.vertical)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(dateValue, format: .dateTime.month(.defaultDigits).day(.twoDigits))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let number = value.as(Double.self), number == 0 {
                    // Using zero opacity to hide 0.
                    AxisGridLine().foregroundStyle(.gray.opacity(0))
                    AxisTick().foregroundStyle(.gray.opacity(0))
                    AxisValueLabel().foregroundStyle(.gray.opacity(0))
                } else {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

//MARK: Volume over time
extension ExerciseAndCategoryChartsView {
    
    // Computed property for the total volume of weight lifted per day.
    private var volumeChartData: [ChartDataPoint] {
        aggregateData { (workoutsForDay: [Workout]) -> Double? in
            guard !workoutsForDay.isEmpty else { return nil }
            return workoutsForDay.reduce(0.0) { total, workout in
                total + workout.exercises.reduce(0.0) { sum, exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        if exercise.templateId == exerciseTemplate.id {
                            return sum + exercise.sets.reduce(0.0) { volume, set in
                                volume + (set.weight * Double(set.reps))
                            }
                        } else { return sum }
                    case .category(let category):
                        if exercise.category?.id == category.id {
                            return sum + exercise.sets.reduce(0.0) { volume, set in
                                volume + (set.weight * Double(set.reps))
                            }
                        } else { return sum }
                        
                    default: //default breaks
                        return sum
                    }
                }
            }
        }
    }
    
    //the chart
    private var volumeCountChart: some View {
        Chart(volumeChartData) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Total Volume", point.value)
            )
            .clipShape(Capsule())
        }
        .padding(.vertical)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(dateValue, format: .dateTime.month(.defaultDigits).day(.twoDigits))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let number = value.as(Double.self), number == 0 {
                    // Using zero opacity to hide 0.
                    AxisGridLine().foregroundStyle(.gray.opacity(0))
                    AxisTick().foregroundStyle(.gray.opacity(0))
                    AxisValueLabel().foregroundStyle(.gray.opacity(0))
                } else {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

//MARK: Median Weight over time
extension ExerciseAndCategoryChartsView {

    //median data
    private var medianChartData: [ChartDataPoint] {
        aggregateData { (workoutsForDay: [Workout]) -> Double? in
            // Gather all weight values for the day
            let weights: [Double] = workoutsForDay.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        return exercise.templateId == exerciseTemplate.id ? exercise.sets.map { Double($0.weight) } : []
                    case .category(let category):
                        return exercise.category?.id == category.id ? exercise.sets.map { Double($0.weight) } : []
                        
                    default: //default is category
                        return []
                    }
                }
            }
            guard !weights.isEmpty else { return nil }
            let sorted = weights.sorted()
            if sorted.count % 2 == 0 {
                let mid = sorted.count / 2
                return (sorted[mid - 1] + sorted[mid]) / 2.0
            } else {
                return sorted[sorted.count / 2]
            }
        }
    }

    //max data
    private var maxChartData: [ChartDataPoint] {
        aggregateData { (workoutsForDay: [Workout]) -> Double? in
            // Gather all weight values for the day
            let weights: [Double] = workoutsForDay.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        return exercise.templateId == exerciseTemplate.id ? exercise.sets.map { Double($0.weight) } : []
                    case .category(let category):
                        return exercise.category?.id == category.id ? exercise.sets.map { Double($0.weight) } : []
                    default: //default is category
                        return []
                    }
                }
            }
            // Return nil if there are no weight values (i.e. no workouts for the day)
            guard !weights.isEmpty else { return nil }
            return weights.max()
        }
    }

    //min data
    private var minChartData: [ChartDataPoint] {
        aggregateData { (workoutsForDay: [Workout]) -> Double? in
            // Gather all weight values for the day
            let weights: [Double] = workoutsForDay.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        return exercise.templateId == exerciseTemplate.id ? exercise.sets.map { Double($0.weight) } : []
                    case .category(let category):
                        return exercise.category?.id == category.id ? exercise.sets.map { Double($0.weight) } : []
                    default: //default is category
                        return []
                    }
                }
            }
            // Only return a value if data exists for that day.
            guard !weights.isEmpty else { return nil }
            return weights.min()
        }
    }
    
    //used to create the barmark between min and max values for a day
    struct CandlestickData: Identifiable {
        let id = UUID()
        let date: Date
        let min: Double
        let max: Double
    }
    
    //candle stick data array
    private var candlestickData: [CandlestickData] {
        // Zip minChartData and maxChartData together.
        return zip(minChartData, maxChartData).compactMap { (minPoint, maxPoint) in
            // Ensure the dates match (to be safe).
            if Calendar.current.isDate(minPoint.date, inSameDayAs: maxPoint.date) {
                return CandlestickData(date: minPoint.date, min: minPoint.value, max: maxPoint.value)
            }
            return nil
        }
    }
    
    //chart
    private var medianWeightChart: some View {
        
        Chart {
            
            //candlesticks
            ForEach(candlestickData) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    yStart: .value("Min Weight", point.min),
                    yEnd: .value("Max Weight", point.max),
                    width: MarkDimension(floatLiteral: markerSize-1)
                )
                .cornerRadius(markerSize / 2) // Capsule-like appearance.
                .foregroundStyle(.blue.opacity(0.4))
            }
            
            //median line
            ForEach(medianChartData) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Median Weight", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue.opacity(0.8))
                .lineStyle(StrokeStyle(lineWidth: 4))
            }
            
            //median data point markers
            ForEach(medianChartData) { point in
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Median Weight", point.value)
                )
                .symbol {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: markerSize, height: markerSize)
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: markerSize, height: markerSize)
                    }
                }
            }
            

        }
        .padding(.vertical)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(dateValue, format: .dateTime.month(.defaultDigits).day(.twoDigits))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let number = value.as(Double.self), number == 0 {
                    AxisGridLine().foregroundStyle(.gray.opacity(0))
                    AxisTick().foregroundStyle(.gray.opacity(0))
                    AxisValueLabel().foregroundStyle(.gray.opacity(0))
                } else {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}
