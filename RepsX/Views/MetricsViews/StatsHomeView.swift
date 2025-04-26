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
    case editTargetGoal(TargetGoal, ExerciseTemplate)
    case addGoal
    
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
    //goals
    @Query(sort: \ConsistencyGoal.name, order: .reverse) var consistencyGoals: [ConsistencyGoal]
    @Query(sort: \TargetGoal.name, order: .reverse) var targetGoals: [TargetGoal]
    //exerciseTemplates
    @Query(sort: \ExerciseTemplate.name) var exerciseTemplates: [ExerciseTemplate]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    //View Models
    private var consistencyGoalViewModel: ConsistencyGoalViewModel {
        ConsistencyGoalViewModel(modelContext: modelContext)
    }
    
    private var targetGoalViewModel: TargetGoalViewModel {
        TargetGoalViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        List {
            
            //goals
            Section(header:
                        HStack{
                Text("Goals")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                
            ) {
                //existing goals
                //TODO: bug when deleting an exercise from a workout. FIX
                ForEach(consistencyGoals){goal in
                    NavigationLink(value: StatsDestination.editConsistencyGoal(goal)){
                        //recurringGoalRow(goal:goal, workouts: workouts)
                        RecurringGoalRowView(goal: goal)
                    }
                }
                ForEach(targetGoals){goal in
                    let exerciseTemplate = getExerciseTemplate(for: goal.exerciseId, from: exerciseTemplates)
                    NavigationLink(value: StatsDestination.editTargetGoal(goal, exerciseTemplate) ) {
                            TargetGoalRowView(goal: goal)
                        }
                    
                }
                //add goals
                NavigationLink(value: StatsDestination.addGoal) {
                    HStack{
                        Text("Add new goal")
                        Spacer()
                    }
                    .foregroundStyle(themeColor)
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
                
            //goals
            case .addGoal:
                NewGoalView()
            case .editConsistencyGoal(let goal):
                EditRecurringGoal(goal: goal, workouts: workouts)
            case .editTargetGoal(let goal, let template):
                EditTargetGoalView(goal: goal, workouts: workouts, exerciseTemplate: template, filter: .exercise(template))
                
            }
        }
        .listSectionSpacing(12)
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(themeColor: themeColor)
        )
        .tint(themeColor)
        .contentMargins(.horizontal,16)
        
    }
}

//MARK: functions
extension StatsHomeView {
    
    func getExerciseTemplate(
        for exerciseId: UUID,
        from exercises: [ExerciseTemplate]
    ) -> ExerciseTemplate {
        guard let template = exercises.first(where: { $0.id == exerciseId }) else {
            fatalError("ExerciseTemplate with ID \(exerciseId) not found")
        }
        return template
    }
    
}


#Preview {
    
    let testTargetGoal = TargetGoal(name: "test target", exerciseId: UUID(), type: .strength, targetPrimaryValue: 225, targetSecondaryValue: 5)
    
    NavigationStack{
        StatsHomeView()
            .navigationTitle("Stats")
    }
    
}






