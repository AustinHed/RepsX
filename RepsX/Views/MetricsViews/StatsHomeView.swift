//
//  StatsView.swift
//  RepsX
//
//  Created by Austin Hed on 3/5/25.
//

import SwiftUI
import Charts
import SwiftData

enum StatsDestination: Hashable {

    case exercise
    case category
    
    case duration
    case volume
    case sets
    case reps
    case intensity
    
}

// Example StatsView
struct StatsHomeView: View {
    
    //MARK: Queries
    // Fetch workouts from SwiftData for hte 30 days, to allow filtering 30 or 14 days
    @Query(filter: Workout.currentPredicate(),
           sort: \Workout.startTime) var workouts: [Workout]
    //fetch all exercises for the L30D
    @Query(filter: Exercise.currentPredicate()
    ) var exercisesList: [Exercise]
    //filter into a usable array, based on the lookback date
    @State var lookback: Int = 30
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let thresholdDate = calendar.date(byAdding: .day, value: -lookback, to: Date())!
        return workouts.filter{ $0.startTime > thresholdDate }
    }
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    var body: some View {

        List {
            
            Section("30-Day Recap"){
                if workouts.count < 7 {
                    Text("Please log at least 7 workouts to see your 30-day recap")
                } else {
                    
                    HStack{
                        workoutCountAndMinutes
                    }
                    VStack{
                        HStack{
                            Text("Exercises by category")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        HStack{
                            pieChartView
                            categoryTextList
                        }
                    }
                    
                }
                
            }
            
            Section("Specific Stats") {
                NavigationLink(value: StatsDestination.exercise) {
                    Text("Exercise")
                }
                
                NavigationLink(value: StatsDestination.category) {
                    Text("Category")
                }
                
            }
            
            Section("Overall Stats"){
                //favorite exercises
                //favorite categories
                NavigationLink(value: StatsDestination.duration) {
                    Text("Workout Duration")
                }
                NavigationLink(value: StatsDestination.volume) {
                    Text("Workout Volume")
                }
                NavigationLink(value: StatsDestination.sets) {
                    Text("Total Sets")
                }
                NavigationLink(value: StatsDestination.reps) {
                    Text("Total Reps")
                }
                NavigationLink(value: StatsDestination.intensity) {
                    Text("Set Intensity")
                }
            }
        }
        .navigationTitle("Stats")
        //MARK: Destination
        .navigationDestination(for: StatsDestination.self) {
            destination in
            switch destination {
            case .exercise:
                ListOfExerciseTemplatesView(navigationTitle: "Select an Exercise", allWorkouts: workouts) { exercise in
                    ExerciseAndCategoryChartsView(filter: .exercise(exercise), workouts: workouts)
                }
            case .category:
                ListOfCategoriesView(navigationTitle:"Select a Category", allWorkouts: workouts) {
                    category in
                    ExerciseAndCategoryChartsView(filter: .category(category), workouts: workouts)
                }
            case .duration:
                GeneralChartsView(filter: .length, workouts: workouts)
            case .volume:
                GeneralChartsView(filter: .volume, workouts: workouts)
            case .sets:
                GeneralChartsView(filter: .sets, workouts: workouts)
            case .reps:
                GeneralChartsView(filter: .reps, workouts: workouts)
            case .intensity:
                GeneralChartsView(filter: .intensity, workouts: workouts)
            }
        }
        .listSectionSpacing(12)
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 50)
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        .tint(themeColor)
    }
}

//MARK: Workouts logged & time
extension StatsHomeView {
    //count of workouts in last X days
    private var workoutCount: Int {
        filteredWorkouts.count
    }
    
    //sum of workout duration in last X days
    private var totalWorkoutDuration: TimeInterval {
        let duration = filteredWorkouts.reduce(0) {$0 + $1.workoutLength}
        return duration / 60 //time intervals are in seconds
    }
    
    private var workoutNumber: some View {
            return Text("\(workoutCount)")
                .font(.largeTitle)
                .bold() +
            Text(" workouts")
                .font(.footnote)
                .foregroundStyle(.secondary)
    }
    private var workoutMinutes: some View {
        return Text("\(totalWorkoutDuration, specifier: "%.0f")")
            .font(.largeTitle)
            .bold() +
        Text(" minutes")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    
    private var workoutCountAndMinutes: some View {
        HStack {
            workoutNumber
            workoutMinutes
        }
    }

}

//MARK: Categories
extension StatsHomeView {
    private var overallCategoryDistribution: [(category: String, count: Int, percentage: Double)] {
        let exercises = exercisesList
        var frequency: [String: Int] = [:]
        
        for exercise in exercises {
            //only include valid, non-hidden categories
            if exercise.category?.isHidden != true {
                if let categoryName = exercise.category?.name {
                    if !categoryName.isEmpty {
                        frequency[categoryName, default : 0] += 1
                    }
                }
            }
        }
        
        let total = frequency.values.reduce(0, +)
        
        return frequency.map { (category: $0.key,
                                count: $0.value,
                                percentage: total > 0 ? (Double($0.value) / Double(total) * 100) : 0)
        }
        .sorted {$0.count > $1.count}
    }
    
    private var categoryTextList: some View {
        VStack(alignment:.leading) {
            let totalEntries = overallCategoryDistribution.count
            ForEach(Array(overallCategoryDistribution.enumerated()), id: \.element.category) { (index, entry) in
                let fraction = totalEntries > 1 ? Double(index) / Double(totalEntries - 1) : 0.0
                let opacity = 1.0 - fraction * 0.6
                let blended = blendedColor(from:themeColor, to: .gray, fraction: fraction)
                
                HStack{
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(blended)
                    Text("\(entry.category)")
                    Spacer()
                    Text("\(entry.percentage, specifier: "%.0f")%")
                }
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
        }
        .padding()
    }
    
    private func blendedColor(from: Color, to: Color, fraction: Double) -> Color {
        let uiFrom = UIColor(from)
        let uiTo = UIColor(to)
        
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        uiFrom.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        uiTo.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + CGFloat(fraction) * (toRed - fromRed)
        let green = fromGreen + CGFloat(fraction) * (toGreen - fromGreen)
        let blue = fromBlue + CGFloat(fraction) * (toBlue - fromBlue)
        let alpha = fromAlpha + CGFloat(fraction) * (toAlpha - fromAlpha)
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
    
    private var pieChartView: some View {
        Chart {
            let totalEntries = overallCategoryDistribution.count
            ForEach(Array(overallCategoryDistribution.enumerated()), id: \.element.category) { (index, entry) in
                //determine the order, and the color based on the order
                let fraction = totalEntries > 1 ? Double(index) / Double(totalEntries - 1) : 0.0
                let opacity = 1.0 - fraction * 0.6
                let blended = blendedColor(from:themeColor, to: .gray, fraction: fraction)
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.6), // Use a ratio value to get a donut look
                    angularInset: 2           // Adds separation between slices
                )
                .cornerRadius(4)
                .foregroundStyle(blended.opacity(opacity))
            }
        }
        .frame(height: 125)
    }
}

//MARK: Query predicates
extension Workout {
    static func currentPredicate() -> Predicate<Workout> {
        let currentDate = Date.now
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
        
        return #Predicate<Workout> { workout in
            workout.startTime > fourteenDaysAgo
        }
    }
}
extension Exercise {
    static func currentPredicate() -> Predicate<Exercise> {
        let currentDate = Date.now
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
        
        return #Predicate<Exercise> { exercise in
            //if the exercise does not have a parent workout, just give it a date that will ensure it doesn't show up
            exercise.workout?.startTime ?? fourteenDaysAgo > fourteenDaysAgo &&
            //exercise must have a category associated
                exercise.category != nil
        }
    }
}

#Preview {
    StatsHomeView()
}


