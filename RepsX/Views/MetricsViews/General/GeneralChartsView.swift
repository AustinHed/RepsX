import SwiftUI
import Charts


/// A view that charts one generic workout metric (duration, volume, sets, reps, or intensity) by day.
struct GeneralChartsView: View {
    
    let filter: ChartFilter  // Should be one of the generic cases.
    let workouts: [Workout]
    
    // Ensure that this view is only used with generic filters.
    init(filter: ChartFilter, workouts: [Workout]) {
        self.filter = filter
        self.workouts = workouts
    }
    
    @Environment(\.themeColor) var themeColor
    
    @State private var selectedGeneralDataPoint: ChartDataPoint? = nil
    
    // A date formatter for display purposes.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
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
    
    // Filter workouts based on the selected lookback period.
    private var recentWorkouts: [Workout] {
        if let period = lookbackPeriod {
            return workouts.filter { $0.startTime >= period }
        } else {
            return workouts // "All Time" selected – no filtering.
        }
    }
    
    //for the custom picker animation
    @Namespace private var pickerAnimation

    
    var body: some View {
        
        ScrollView{
            customPicker()
                .frame(height: 35)
                .background(
                    Capsule()
                        .fill(Color.white)
                )
                .padding(.horizontal, 18)
                .padding(.top, 10)
            
            //content
            if chartData.isEmpty {
                Text("Not enough for the selected time period. Please log additional workouts and check back later.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .navigationTitle(filter.navigationTitle)
            } else {
                LazyVStack(spacing: 12){
                    
                    //summary text
                    StatsSummaryView(dataPoints: chartData, filter: filter, lookback: selectedLookback)
                    
                    
                    //chart
                    ExpandableChartView(title: chartTitle, chartType: filter) {
                        generalChart
                    }
                    
                    //button to more details
                    generalHistoryNavigationLink(dataPoints: chartData, filter: filter)
                    
                    Spacer()
                }
            }
            
            
        }
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 50)
        }
        .navigationTitle(filter.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        
    }
}

//MARK: Chart datapoints
extension GeneralChartsView {
    /// Aggregates the provided workouts by day.
    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        // If there are no workouts, default the startDate to today.
        let startDate = recentWorkouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
        
        // Group workouts by the start of their day.
        let grouped = Dictionary(grouping: recentWorkouts, by: { calendar.startOfDay(for: $0.startTime) })
        var points: [ChartDataPoint] = []
        var currentDate = startDate
        
        // Iterate day by day from the start date until today.
        while currentDate <= endDate {
            let workoutsForDay = grouped[currentDate] ?? []
            let value: Double?
            
            switch filter {
                
            case .length:
                // Sum the workout lengths (in minutes).
                value = workoutsForDay.isEmpty ? nil : workoutsForDay.reduce(0.0) { $0 + $1.workoutLength } / 60.0
                
            case .volume:
                // Compute volume as the sum of (set.weight * set.reps) for each workout.
                value = workoutsForDay.isEmpty ? nil : workoutsForDay.reduce(0.0) { total, workout in
                    total + workout.exercises.reduce(0.0) { sum, exercise in
                        sum + exercise.sets.reduce(0.0) { s, set in s + (set.weight * Double(set.reps)) }
                    }
                }
                
            case .sets:
                // Total number of sets performed.
                value = workoutsForDay.isEmpty ? nil : Double(workoutsForDay.reduce(0) { total, workout in
                    total + workout.exercises.reduce(0) { count, exercise in count + exercise.sets.count }
                })
                
            case .reps:
                // Total number of reps performed.
                value = workoutsForDay.isEmpty ? nil : Double(workoutsForDay.reduce(0) { total, workout in
                    total + workout.exercises.reduce(0) { count, exercise in
                        count + exercise.sets.reduce(0) { s, set in s + set.reps }
                    }
                })
                
                //TODO: Fix intensity case
            case .intensity:
                // Average intensity for all sets performed on that day.
                let intensities: [Double] = workoutsForDay.flatMap { workout in
                    workout.exercises.flatMap { exercise in
                        exercise.sets.compactMap { set in
                            guard let intensity = set.intensity else { return nil }
                            return Double(intensity)
                        }
                    }
                }
                value = intensities.isEmpty ? nil : intensities.reduce(0, +) / Double(intensities.count)
                
            default:
                // Should never happen because of our initializer check.
                value = nil
            }
            
            if let metricValue = value {
                points.append(ChartDataPoint(date: currentDate, value: metricValue))
            }
            
            // Move to the next day.
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return points.sorted { $0.date < $1.date }
    }
}

//MARK: Chart title
extension GeneralChartsView {
    private var chartTitle: String {
        switch filter {
        case .length:
            return "Daily Workout Duration"
        case .volume:
            return "Daily Volume Lifted"
        case .sets:
            return "Daily Sets Completed"
        case .reps:
            return "Daily Reps Completed"
        case .intensity:
            return "Daily Intensity Score"
        default:
            //should never happen
            return "General Chart"
        }
    }
}

//MARK: X Axis Labels
extension GeneralChartsView {
    // Calculate the stride based on the range of dates in chartData.
    private var xAxisStride: Int {
        guard let firstDate = chartData.first?.date,
              let lastDate = chartData.last?.date else { return 1 }
        let totalDays = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        // Target about 6 markers (you can adjust this value as needed)
        let targetTicks = 5
        return max(1, totalDays / targetTicks)
    }
}

//MARK: Chart
extension GeneralChartsView {
    private var generalChart: some View {
        Chart(chartData) { point in
            BarMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Value", point.value)
            )
            //.clipShape(Capsule())
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            if let selected = selectedGeneralDataPoint {
                RuleMark(x: .value("Date", selected.date, unit: .day))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: []))
                    .foregroundStyle(themeColor)
            }
        }
        .interactiveChartOverlay(data: chartData, selectedDataPoint: $selectedGeneralDataPoint) { $0.date }
        .overlay {
            // Write the selected data point to the preference.
            if let selected = selectedGeneralDataPoint {
                Color.clear.preference(key: ChartDataPointPreferenceKey.self, value: selected)
            }
        }
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
        .padding(.vertical)
    }
}

//MARK: General History Button
extension GeneralChartsView {
    func generalHistoryNavigationLink(dataPoints: [ChartDataPoint], filter: ChartFilter) -> some View {
        NavigationLink {
            GeneralHistoryView(dataPoints: dataPoints, filter: filter)
        } label: {
            HStack {
                Text("History")
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

#Preview {
    NavigationStack{
            GeneralChartsView(filter: .length, workouts: [])
    }
    
    
}

//MARK: Custom picker
extension GeneralChartsView {

    func customPicker() -> some View {
        HStack(spacing: 0) {
            ForEach(LookbackOption.allCases, id: \.self) { option in
                Button {
                    // Animate the change of the selected lookback option.
                    withAnimation(.bouncy) {
                        selectedLookback = option
                    }
                } label: {
                    customPickerItem(title: option.description, isActive: (option == selectedLookback))
                }
            }
        }
        .padding(.horizontal, 3)
    }

    func customPickerItem(title: String, isActive: Bool) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(.black)
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Only add the background for the active option.
                    if isActive {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(themeColor.opacity(0.3))
                            // Use matchedGeometryEffect with a shared id.
                            .matchedGeometryEffect(id: "pickerBackground", in: pickerAnimation)
                    }
                }
            )
            .cornerRadius(30)
    }
}



