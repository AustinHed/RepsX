//
//  EditRoutine.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import UIKit

struct EditRoutine: View {
    
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
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //Add Exercise
    @State private var isSelectingExercise: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                //start button
                Section {
                    Button("Start Workout"){
                        //first, create a new workout from the current routine
                        let newWorkout = workoutViewModel.addWorkoutFromRoutine(routine, date: Date())
                        //then, pass that workout to the singleton WorkoutCoordinator to be used in LogView
                        WorkoutCoordinator.shared.currentWorkout = newWorkout
                        WorkoutCoordinator.shared.showEditWorkout = true
                        //then, tell the TabView to navigate to .log
                        selectedTab = .history
                        //finally, dismiss the EditRoutineView
                        dismiss()
                    }
                    .foregroundStyle(userThemeViewModel.primaryColor)
                    
                }
                
                //name
                nameAndColorSection(routine: routine, routineViewModel: routineViewModel)
                
                //exercises
                exercisesSection(for: routine)
                
                //add exercise button
                addExerciseButton(isSelectingExercise: $isSelectingExercise)
                
            }
            .navigationTitle(routine.name == "" ? "New Routine" : routine.name)
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
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "star.fill")
                            }
                        }
                        
                        //reorder exercises
                        Button {
                            //reorder
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
                    .foregroundStyle(userThemeViewModel.primaryColor)
                    
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
                            print(exerciseTemplate)
                            //dismiss
                            isSelectingExercise = false
                            
                        }
                    )
                }
            }
            
        }
        .tint(userThemeViewModel.primaryColor)
    }
}

//MARK: Start button
extension EditRoutine {
    //TODO: Edit routines
}

//MARK: Name
extension EditRoutine {
    func nameAndColorSection(
        routine: Routine,
        routineViewModel: RoutineViewModel
    ) -> some View {
        Section {
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

//MARK: Exercise Rows
extension EditRoutine {
    func exercisesSection(for routine: Routine) -> some View {
        Section{
            ForEach(routine.exercises, id: \.self) { exercise in
                NavigationLink {
                    EditExerciseInRoutineView(exerciseInRoutine: exercise)
                } label: {
                    //TODO: what if not sets
                    VStack(alignment:.leading){
                        Text(exercise.exerciseName)
                            .foregroundStyle(.black)
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
            .foregroundStyle(userThemeViewModel.primaryColor)
        }
    }
}
