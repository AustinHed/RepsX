//
//  EditRoutine.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import UIKit

struct EditRoutine: View {
    
    //Query
    @Query(sort: \RoutineGroup.name) var groups: [RoutineGroup]
    
    //the routine to edit
    var routine: Routine
    
    //Tab View
    @Binding var selectedTab: ContentView.Tab
    
    //Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //ViewModels
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    private var routineViewModel: RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    private var exerciseInRoutineViewModel: ExerciseInRoutineViewModel {
        ExerciseInRoutineViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //Add Exercise
    @State private var isSelectingExercise: Bool = false
    @State private var isReordering: Bool = false
    
    var body: some View {
        List {
            //start button
            Section {
                Button {
                    //first, create a new workout from the current routine
                    let newWorkout = workoutViewModel.addWorkoutFromRoutine(routine, date: Date())
                    //then, pass that workout to the singleton WorkoutCoordinator to be used in LogView
                    WorkoutCoordinator.shared.currentWorkout = newWorkout
                    WorkoutCoordinator.shared.showEditWorkout = true
                    selectedTab = .history
                    dismiss()
                } label: {
                    Text("Start Workout")
                        .bold()
                }
                .foregroundStyle(primaryColor)
                
            }
            //name
            nameSection(routine: routine, routineViewModel: routineViewModel)
            
            //group
            groupSection(routine: routine, routineViewModel: routineViewModel, groups: groups)
            
            //exercises
            exercisesSection(for: routine)
            
            //add exercise button
            addExerciseButton(isSelectingExercise: $isSelectingExercise)
            
        }
        .navigationDestination(for: ExerciseInRoutine.self, destination: { exercise in
            EditExerciseInRoutineView(exerciseInRoutine: exercise)
        })
        .navigationTitle(routine.name == "" ? "New Routine" : routine.name)
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    //favorite routine
                    Button (role: routine.favorite ? .destructive : nil){
                        routineViewModel.favoriteRoutine(routine)
                        print(routine.favorite)
                    } label: {
                        HStack{
                            Text(routine.favorite ? "Unfavorite" : "Favorite")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Image(systemName: "star.fill")
                        }
                    }
                    
                    //reorder exercises
                    Button {
                        isReordering.toggle()
                    } label: {
                        HStack{
                            Text("Reorder")
                            Spacer()
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    
                    //delete specific routine
                    Button (role:.destructive) {
                        //dismiss
                        dismiss()
                        //delete
                        routineViewModel.deleteRoutine(routine)
                    } label: {
                        HStack{
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .foregroundStyle(primaryColor)
                
            }
        }
        //MARK: Sheets
        //add exercise
        .sheet(isPresented: $isSelectingExercise) {
            NavigationStack{
                SelectCategoryView(
                    isSelectingExercise: $isSelectingExercise,
                    onExerciseSelected: { exerciseTemplate in
                        //take the selected Exercise and add an ExerciseTemplate
                        routineViewModel.addExerciseInRoutine(to: routine, exercise: exerciseTemplate)
                        //dismiss
                        isSelectingExercise = false
                        
                    }
                )
            }
        }
        .sheet(isPresented: $isReordering) {
           ReorderExercisesInRoutineView(
                routine: routine,
                exerciseInRoutineViewModel:exerciseInRoutineViewModel
            )
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
        .tint(primaryColor)
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
    }
}

//MARK: Name
extension EditRoutine {
    func nameSection(
        routine: Routine,
        routineViewModel: RoutineViewModel
    ) -> some View {
        Section (header:
                    HStack{
            Text("Name")
                .font(.headline)
                .bold()
                .foregroundStyle(Color.primary)
                .textCase(nil)
            Spacer()
        }
            .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
        ) {
            // Edit Name
            TextField("Name this Routine", text: Binding(
                get: { routine.name },
                set: { newName in
                    routine.name = newName.isEmpty ? "" : newName
                }
            ))
            .onSubmit {
                routineViewModel.updateRoutine(routine, newName: routine.name)
            }
        }
    }
}

//MARK: Group
extension EditRoutine {
    func groupSection(
        routine: Routine,
        routineViewModel: RoutineViewModel,
        groups: [RoutineGroup]
    ) -> some View {
        Section (header:
                    HStack{
            Text("Assign Group")
                .font(.headline)
                .bold()
                .foregroundStyle(Color.primary)
                .textCase(nil)
            Spacer()
        }
            .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
        ) {
            Picker("Group", selection: Binding<RoutineGroup?>(
                get: { routine.group },
                set: { newGroup in
                    routine.group = newGroup
                }
            )) {
                Text("None").tag(RoutineGroup?.none)
                ForEach(groups) { group in
                    Text(group.name).tag(Optional(group))
                }
            }
        }
    }
}

//MARK: Exercise Rows
extension EditRoutine {
    func exercisesSection(for routine: Routine) -> some View {
        Section (header:
                    HStack{
            Text("Exercises")
                .font(.headline)
                .bold()
                .foregroundStyle(Color.primary)
                .textCase(nil)
            Spacer()
        }
            .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
        ){
            ForEach(routine.exercises.sorted {$0.order < $1.order}, id: \.self) { exercise in
                NavigationLink(value: exercise) {
                    VStack(alignment:.leading){
                        Text(exercise.exerciseName)
                            .foregroundStyle(Color.primary)
                        Text("\(exercise.setCount) Sets")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                    }
                }
            }
        }
    }
}

//MARK: Add Exercise button
extension EditRoutine {
    func addExerciseButton(isSelectingExercise: Binding <Bool>) -> some View{
        Section{
            Button {
                isSelectingExercise.wrappedValue.toggle()
            } label: {
                Text("Add Exercise")
            }
            .foregroundStyle(primaryColor)
        }
    }
}
