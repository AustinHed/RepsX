import SwiftUI
import Charts
import SwiftData

struct ExerciseOverTimeChartView: View {
    
    // Used to show either Exercise or Category data based on the filter provided.
    // Also updates the navigation title.
    let filter: ChartFilter
    
    // Passed in list of all workouts, pre-filtered for the given exercise
    let workouts: [Workout]
    
    // Store the selected lookback option.
    @State private var selectedLookback: LookbackOption = .seven
    
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
    
    // Filter workouts based on the selected lookback period.
    private var recentWorkouts: [Workout] {
        if let period = lookbackPeriod {
            return workouts.filter { $0.startTime >= period }
        } else {
            return workouts // "All Time" selected – no filtering.
        }
    }
    
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
                    //goes to an ExerciseHistoryView
                    //takes a filtered list of Workouts, transforms it into a List showing the date, weight, reps for a given exercise
                    Button {
                        //action
                    } label: {
                        HStack{
                            Text("Exercise History")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }

                    
                }
                .navigationTitle(filter.navigationTitle)
                .padding(.vertical, 30)
                
                
            }
            .background(Color(UIColor.systemGroupedBackground))

        }
    }
    
    
}
//MARK: Workout History

//MARK: xAxisStride
extension ExerciseOverTimeChartView {
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

//MARK: Sets over time
extension ExerciseOverTimeChartView {
    
    // Computed property that aggregates chart data across the full selected date range.
    private var setChartData: [ChartDataPoint] {
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
        
        // Group workouts by day.
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            if let dayWorkouts = grouped[currentDate], !dayWorkouts.isEmpty {
                let totalSets = dayWorkouts.reduce(0) { total, workout in
                    total + workout.exercises.reduce(0) { sum, exercise in
                        switch filter {
                        case .exercise(let exerciseTemplate):
                            return exercise.templateId == exerciseTemplate.id ? sum + exercise.sets.count : sum
                        case .category(let category):
                            return exercise.category?.id == category.id ? sum + exercise.sets.count : sum
                        }
                    }
                }
                points.append(ChartDataPoint(date: currentDate, value: Double(totalSets)))
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return points.sorted { $0.date < $1.date }
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
extension ExerciseOverTimeChartView {
    
    // Computed property for the total volume of weight lifted per day.
    private var volumeChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            if selectedLookback == .all {
                return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
            } else {
                return lookbackPeriod ?? endDate
            }
        }()
        
        let filteredWorkouts = workouts.filter { workout in
            let workoutDay = calendar.startOfDay(for: workout.startTime)
            return workoutDay >= startDate && workoutDay <= endDate
        }
        
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            if let dayWorkouts = grouped[currentDate], !dayWorkouts.isEmpty {
                // Compute total volume (assumes each set has weight and reps)
                let totalVolume = dayWorkouts.reduce(0.0) { total, workout in
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
                        }
                    }
                }
                points.append(ChartDataPoint(date: currentDate, value: totalVolume))
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return points.sorted { $0.date < $1.date }
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
extension ExerciseOverTimeChartView {

    //median data
    private var medianChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            if selectedLookback == .all {
                return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
            } else {
                return lookbackPeriod ?? endDate
            }
        }()
        
        let filteredWorkouts = workouts.filter { workout in
            let workoutDay = calendar.startOfDay(for: workout.startTime)
            return workoutDay >= startDate && workoutDay <= endDate
        }
        
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            let dayWorkouts = grouped[currentDate] ?? []
            let weights: [Double] = dayWorkouts.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        if exercise.templateId == exerciseTemplate.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else { return [] }
                    case .category(let category):
                        if exercise.category?.id == category.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else { return [] }
                    }
                }
            }
            
            if !weights.isEmpty {
                let median: Double
                if weights.isEmpty {
                    median = 0.0
                } else {
                    let sorted = weights.sorted()
                    if sorted.count % 2 == 0 {
                        let mid = sorted.count / 2
                        median = (sorted[mid - 1] + sorted[mid]) / 2.0
                    } else {
                        median = sorted[sorted.count / 2]
                    }
                }
                points.append(ChartDataPoint(date: currentDate, value: median))
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
            
        }
        
        return points.sorted { $0.date < $1.date }
    }

    //max data
    private var maxChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            if selectedLookback == .all {
                return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
            } else {
                return lookbackPeriod ?? endDate
            }
        }()
        
        let filteredWorkouts = workouts.filter { workout in
            let workoutDay = calendar.startOfDay(for: workout.startTime)
            return workoutDay >= startDate && workoutDay <= endDate
        }
        
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            let dayWorkouts = grouped[currentDate] ?? []
            let weights: [Double] = dayWorkouts.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        if exercise.templateId == exerciseTemplate.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else { return [] }
                    case .category(let category):
                        if exercise.category?.id == category.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else { return [] }
                    }
                }
            }
            
            //only append values if there was actually a workout that day
            if !weights.isEmpty {
                let maxValue = weights.max() ?? 0.0
                points.append(ChartDataPoint(date: currentDate, value: maxValue))
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return points.sorted { $0.date < $1.date }
    }

    //min data
    private var minChartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            if selectedLookback == .all {
                return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
            } else {
                return lookbackPeriod ?? endDate
            }
        }()
        
        let filteredWorkouts = workouts.filter { workout in
            let workoutDay = calendar.startOfDay(for: workout.startTime)
            return workoutDay >= startDate && workoutDay <= endDate
        }
        
        let grouped = Dictionary(grouping: filteredWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        while currentDate <= endDate {
            let dayWorkouts = grouped[currentDate] ?? []
            let weights: [Double] = dayWorkouts.flatMap { workout in
                workout.exercises.flatMap { exercise in
                    switch filter {
                    case .exercise(let exerciseTemplate):
                        if exercise.templateId == exerciseTemplate.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else {
                            return []
                        }
                    case .category(let category):
                        if exercise.category?.id == category.id {
                            return exercise.sets.map { Double($0.weight) }
                        } else {
                            return []
                        }
                    }
                }
            }
            
            // Only append a min value if there is data for that day.
            if !weights.isEmpty {
                let minValue = weights.min()!
                points.append(ChartDataPoint(date: currentDate, value: minValue))
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return points.sorted { $0.date < $1.date }
    }

    private var medianWeightChart: some View {
        Chart {
            // Draw the median weight line with smooth, curved interpolation.
            ForEach(medianChartData) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Median Weight", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
            }
            
            // Overlay median data point markers.
            ForEach(medianChartData) { point in
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Median Weight", point.value)
                )
                .symbol(Circle())
                .foregroundStyle(.blue)
            }
            
            // Overlay max weight markers.
            ForEach(maxChartData) { point in
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Max Weight", point.value)
                )
                .symbol(Circle())
                .foregroundStyle(.red)
            }
            
            // Overlay min weight markers.
            ForEach(minChartData) { point in
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Min Weight", point.value)
                )
                .symbol(Circle())
                .foregroundStyle(.green)
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
