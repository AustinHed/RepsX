//
//  AddNewRoutineView.swift
//  RepsX
//
//  Created by Austin Hed on 3/17/25.
//

import SwiftUI

struct AddNewRoutineView: View {
    
    //Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    //the routine
    var routine: Routine
    
    //view models
    private var routineViewModel: RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //add exercise toggle
    @State var isAddingExercise: Bool = false
    
    //toggle alert
    @State var showAlert: Bool = false
    
    //disable save unless 1+ exercises and non-blank name
    var canSaveRoutine: Bool {
        if routine.exercises.isEmpty || routine.name.isEmpty {
            true
        } else {
            false
        }
    }
    
    //empty array of ExerciseInRoutines
    @State private var exercisesInRoutine: [ExerciseInRoutine] = []
    
    var body: some View {
        
        NavigationStack {
            List {
                //name
                Section {
                    nameSection(routine: routine, routineViewModel: routineViewModel)
                }
                //exercises
                Section {
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
                
                Section {
                    Button("Add Exercise") {
                        isAddingExercise.toggle()
                    }
                }
            }
            .navigationTitle("New Routine")
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showAlert.toggle()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        //just closes the editing view
                        dismiss()
                    }
                    .disabled(canSaveRoutine)
                }
            }
            //MARK: Sheets
            .sheet(isPresented: $isAddingExercise) {
                NavigationStack{
                    SelectCategoryView(
                        isSelectingExercise: $isAddingExercise,
                        onExerciseSelected: { exerciseTemplate in
                            routineViewModel.addExerciseInRoutine(to: routine, exercise: exerciseTemplate)
                            isAddingExercise = false
                        }
                        
                    )
                }
            }
            //MARK: Alerts
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Cancel new routine"),
                    message: Text("Are you sure you want to cancel? This routine will not be saved"),
                    primaryButton: .cancel(
                        Text("Cancel"),
                        action: {return}
                    ),
                    secondaryButton: .destructive(
                        Text("Cancel Routines"),
                        action: {
                            //dismiss
                            dismiss()
                            //delete the routine
                            routineViewModel.deleteRoutine(routine)
                        }
                    )
                )
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(themeColor: themeColor)
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}

//MARK: add exercise button
extension AddNewRoutineView {
    func addExerciseButton(isSelectingExercise: Binding <Bool>) -> some View{
        Section{
            Button {
                isSelectingExercise.wrappedValue.toggle()
            } label: {
                Text("Add Exercise")
            }
        }
    }
}

//MARK: edit name
extension AddNewRoutineView {
    func nameSection(
        routine: Routine,
        routineViewModel: RoutineViewModel
    ) -> some View {
        Section {
            // Edit Name
            TextField("New Routine", text: Binding(
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
//#Preview {
//    let newRoutine = Routine(name: "Test", exercises: [])
//    AddNewRoutineView(routine: newRoutine)
//}
