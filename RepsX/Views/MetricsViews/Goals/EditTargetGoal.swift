import SwiftUI
import Charts
import SwiftData

struct EditTargetGoalView: View {
    
    // Passed in list of all workouts
    let workouts: [Workout]
    let goal: TargetGoal
    
    //goal properties
    @State var newName: String = ""
    @State var newPrimaryTarget: Double
    @State var newSecondaryTarget: Double
    @State var showAlert: Bool = false
    
    //init to use custom target values initially
    init(goal: TargetGoal, workouts: [Workout], exerciseTemplate: ExerciseTemplate, filter: ChartFilter) {
        self.goal = goal
        self.workouts = workouts
        self.exerciseTemplate = exerciseTemplate
        self.filter = filter
        _newPrimaryTarget = State(initialValue: goal.targetPrimaryValue)
        _newSecondaryTarget = State(initialValue: goal.targetSecondaryValue)
    }
        
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    //the exerciseTemplateId for use in the button
    private var exerciseTemplate: ExerciseTemplate
    let filter: ChartFilter //always pass an exercise
    let selectedLookback: LookbackOption = .all //always show full history of an exercise
    
    //Charts
    @State private var selectedWeightDataPoint: ChartDataPoint? = nil
    @State private var selectedSetsDataPoint: ChartDataPoint? = nil
    @State private var selectedVolumeDataPoint: ChartDataPoint? = nil
    let markerSize: CGFloat = 8
    //viewModel
    private var targetGoalViewModel:TargetGoalViewModel {
        TargetGoalViewModel(modelContext: modelContext)
    }
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    

    var body: some View {
            ScrollView{
                LazyVStack(alignment:.leading, spacing: 12){
                    //details section
                    Text("Details")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .padding(.leading,3)
                        .padding(.horizontal, 16)
                    editName
                        .padding(.horizontal, 16)
                    editPrimaryTarget
                        .padding(.horizontal, 16)
                    editSecondaryTarget
                        .padding(.horizontal, 16)
                    
                    
                    //Content
                    Text("History")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .padding(.leading,3)
                        .padding(.horizontal, 16)
                    if medianChartData.isEmpty {
                        Text("Not enough for the exercise. Please log additional workouts and check back later.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                    } else {
                            
                            //charts
                            ExpandableChartView(title: "Weight", chartType: filter) {
                                medianWeightChart
                            }
                            
                            ExpandableChartView(title:"Sets", chartType: filter) {
                                setCountChart
                            }
                            
                            Spacer()
                        
                    }
                    
                    //delete
                    Text("Delete")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.primary)
                        .padding(.leading,3)
                        .padding(.horizontal, 16)
                    delete
                        .padding(.horizontal, 16)
                }
                
            }
            .navigationTitle("Edit Goal")
            .safeAreaInset(edge: .bottom) {
                // Add extra space (e.g., 100 points)
                Color.clear.frame(height: 100)
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
            //MARK: Toolbar
            .toolbar {
                //only show if there are changes
                if !newName.isEmpty || newPrimaryTarget != goal.targetPrimaryValue || newSecondaryTarget != goal.targetSecondaryValue {
                    ToolbarItem(placement:.topBarTrailing) {
                        Button {
                            //action
                            targetGoalViewModel.updateGoal(goal,
                                                           newName: newName,
                                                           newPrimaryValue: newPrimaryTarget,
                                                           newSecondaryValue: newSecondaryTarget
                            )
                            dismiss()
                        } label: {
                            Text("Save").bold()
                        }

                    }
                }
            }
            //MARK: Alert
            .alert("Delete this goal?", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) {
                    // Cancel action: simply dismiss the alert.
                    showAlert = false
                }
                Button("Delete", role: .destructive) {
                    // Confirm delete action: handle the deletion here.
                    targetGoalViewModel.deleteGoal(goal)
                    showAlert = false
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this goal? This cannot be undone.")
            }

        
    }
}

//MARK: X Axis Labels
extension EditTargetGoalView {
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
extension EditTargetGoalView {
    // A helper function to aggregate data by day.
    private func aggregateData(using aggregator: ([Workout]) -> Double?) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        let startDate: Date = {
            return workouts.map { calendar.startOfDay(for: $0.startTime) }.min() ?? endDate
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

//MARK: Median Weight over time
extension EditTargetGoalView {

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
                .foregroundStyle(primaryColor.opacity(0.4))
                .opacity(selectedWeightDataPoint == nil || selectedWeightDataPoint?.date == point.date ? 1 : 0.3)
            }
            
            //median line
            ForEach(medianChartData) { point in
                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Median Weight", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(primaryColor.opacity(0.8))
                .opacity(selectedWeightDataPoint == nil ? 1 : 0.3)
                .lineStyle(StrokeStyle(lineWidth: 4))
                
                if let selected = selectedWeightDataPoint {
                    RuleMark(x: .value("Date", selected.date, unit: .day))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: []))
                        .foregroundStyle(primaryColor)
                }
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
                            .fill(primaryColor)
                            .frame(width: markerSize, height: markerSize)
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: markerSize, height: markerSize)
                    }
                    .opacity(selectedWeightDataPoint == nil || selectedWeightDataPoint?.date == point.date ? 1 : 0.3)
                }
                
            }

        }
        .interactiveChartOverlay(data: medianChartData, selectedDataPoint: $selectedWeightDataPoint) { $0.date }
        .overlay {
            // Write the selected data point to the preference.
            if let selected = selectedWeightDataPoint {
                Color.clear.preference(key: ChartDataPointPreferenceKey.self, value: selected)
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

//MARK: Sets over time
extension EditTargetGoalView {
    
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
            //.clipShape(Capsule())
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .opacity(selectedSetsDataPoint == nil || selectedSetsDataPoint?.date == point.date ? 1 : 0.3)
            
            if let selected = selectedSetsDataPoint {
                RuleMark(x: .value("Date", selected.date, unit: .day))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: []))
                    .foregroundStyle(primaryColor)
            }
        }
        .interactiveChartOverlay(data: setChartData, selectedDataPoint: $selectedSetsDataPoint) { $0.date }
        .overlay {
            // Write the selected data point to the preference.
            if let selected = selectedSetsDataPoint {
                Color.clear.preference(key: ChartDataPointPreferenceKey.self, value: selected)
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
extension EditTargetGoalView {
    
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
            //.clipShape(Capsule())
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .opacity(selectedVolumeDataPoint == nil || selectedVolumeDataPoint?.date == point.date ? 1 : 0.3)
            
            //the visual line marker
            if let selected = selectedVolumeDataPoint {
                RuleMark(x: .value("Date", selected.date, unit: .day))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: []))
                    .foregroundStyle(primaryColor)
            }
        }
        .interactiveChartOverlay(data: volumeChartData, selectedDataPoint: $selectedVolumeDataPoint) { $0.date }
        .overlay {
            // Write the selected data point to the preference.
            if let selected = selectedVolumeDataPoint {
                Color.clear.preference(key: ChartDataPointPreferenceKey.self, value: selected)
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

//MARK: Delete Button
extension EditTargetGoalView {
    var delete: some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            Button {
                showAlert.toggle()
            } label: {
                Spacer()
                Text("Delete Goal")
                    .padding(15)
                Spacer()
            }

        }
    }
}

//MARK: Edit Name
extension EditTargetGoalView {
    var editName: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            ZStack (alignment:.leading){
                if newName.isEmpty {
                    Text(goal.name)
                        .foregroundStyle(Color.primary)
                        .padding(.leading, 16)
                }
                TextField("", text: $newName)
                    .padding()
            }
            
        }
    }
}

//MARK: Edit Primary Target
extension EditTargetGoalView {
    var primaryDescriptor: String {
        switch goal.type {
        case .strength:
            return "Lbs"
        case .pace:
            return "Miles"
        }
    }
    
    var editPrimaryTarget: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            
            HStack{
                TextField("\(goal.targetPrimaryValue)", value: $newPrimaryTarget, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 40)
                Text(primaryDescriptor)
                    .foregroundStyle(.secondary)
                Spacer()
                    
            }
            .padding()
            
        }
    }
    
    
}
//MARK: Edit Secondary Target
extension EditTargetGoalView {
    var secondaryDescriptor: String {
        switch goal.type {
        case .strength:
            return "Reps"
        case .pace:
            return "Minutes"
        }
    }
    
    var editSecondaryTarget: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
            
            
            HStack{
                TextField("\(goal.targetSecondaryValue)", value: $newSecondaryTarget, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 40)
                Text(secondaryDescriptor)
                    .foregroundStyle(.secondary)
                Spacer()
                    
            }
            .padding()
            
        }
    }
}

#Preview {
    let testCategory: CategoryModel = CategoryModel(name: "Chest")
    let testExercise: ExerciseTemplate = ExerciseTemplate(name: "Bench Press", category: testCategory, modality: .repetition, hidden: false, standard: true)
    let testGoal: TargetGoal = TargetGoal(name: "225 on Bench", exerciseId: testExercise.id, type: .strength, targetPrimaryValue: 225, targetSecondaryValue: 5)
    
    NavigationStack{
        EditTargetGoalView(goal: testGoal, workouts: [], exerciseTemplate: testExercise, filter: .exercise(testExercise))
    }
    
}

