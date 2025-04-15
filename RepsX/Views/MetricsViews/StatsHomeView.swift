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
    
    case editConsistencyGoal(ConsistencyGoal)
    case addConsistencyGoal
    
    case exercise
    case category
    
    case duration
    case volume
    case sets
    case reps
    case intensity

}

struct StatsHomeView: View {
    
    //MARK: Queries
    //all workouts completed
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    //consistency goals
    @Query(sort: \ConsistencyGoal.name, order: .reverse) var consistencyGoals: [ConsistencyGoal]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    //View Models
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        List {
            
            //consistency goals
            Section(header:
                        HStack{
                Text("Consistency Goals")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                
            ) {
                //existing goals
                ForEach(consistencyGoals){goal in
                    NavigationLink(value: StatsDestination.editConsistencyGoal(goal)){
                        consistencyGoalRow(goal:goal, workouts: workouts)
                    }
                    
                }
                //add goals
                NavigationLink(value: StatsDestination.addConsistencyGoal) {
                    HStack{
                        Text("Add new goal")
                        Spacer()
                    }
                    .foregroundStyle(themeColor)
                }
            }
            
            //strength goals
            Section(header:
                        HStack{
                Text("Strength Goals")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                
            ) {
                
                HStack (alignment:.top) {
                    ZStack{
                        // Full circle (background)
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                        
                        // Progress circle (foreground)
                        Circle()
                            .trim(from: 0.0, to: 0.82)
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: 0.4)
                        
                    }
                    .frame(height: 60)
                    .overlay(
                        Text("82%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    )
                    .padding(.trailing, 10)
                    
                    
                    
                    
                    VStack (alignment:.leading){
                        Text("Placeholder for Strength Goal")
                            .font(.headline)
                        Text("185/225")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Started 1/1/25")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
       
                }

                HStack{
                    Text("Set a new goal")
                    Spacer()
                    Image(systemName: "plus.circle")
                }
                
            }
            //specific stats
            Section(header:
                        HStack{
                Text("Specific Stats")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                
            ) {
                NavigationLink(value: StatsDestination.exercise) {
                    Text("Exercise")
                }
                
                NavigationLink(value: StatsDestination.category) {
                    Text("Category")
                }
                
            }
            //general stats
            Section(header:
                        HStack{
                Text("General Stats")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                
            ){
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
                
            case .addConsistencyGoal:
                NewConsistencyGoalView()
                
            case .editConsistencyGoal(let goal):
                EditConsistencyGoalView(goal: goal, workouts: workouts)
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

//MARK: Consistency Goal Rows
extension StatsHomeView {
    func consistencyGoalRow(goal: ConsistencyGoal, workouts: [Workout]) -> some View {
        let currentProgress = consistencyGoalViewModel.progress(for: goal, from: workouts)
        
        return VStack (alignment: .leading) {
            Text(goal.name)
                .font(.headline)
            HStack{
                Text(goal.goalTimeframe.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                Text("\(Int(currentProgress))/\(Int(goal.goalTarget)) \(goal.goalMeasurement.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: currentProgress, total: goal.goalTarget)
                .progressViewStyle(LinearProgressViewStyle())
        }
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
    NavigationStack{
        StatsHomeView()
            .navigationTitle("Stats")
    }
    
}


