//
//  EditExerciseInRoutineView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import SwiftData


struct EditExerciseInRoutineView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    //the ExerciseInRoutine to edit
    @State var exerciseInRoutine: ExerciseInRoutine
    
    //viewModel
    private var exerciseInRoutineViewModel:ExerciseInRoutineViewModel {
        ExerciseInRoutineViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //replace exercise var
    @State var replaceExerciseInRoutine:Bool = false
    
    var body: some View {
        List{
            Section("Default number of sets"){
                HStack{
                    Text("Sets")
                    Spacer()
                    TextField("Set Count", value: $exerciseInRoutine.setCount, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: exerciseInRoutine.setCount) { oldValue, newValue in
                            if oldValue != newValue {
                                exerciseInRoutineViewModel.updateExerciseInRoutine(exerciseInRoutine, newSetCount: Int(newValue))
                            }
                        }
                    
                }
                
            }
            
            Section{
                Button {
                    replaceExerciseInRoutine.toggle()
                    //TODO: Replace
                    //show select cat view
                    //show list of exercises view
                    //replace existing exerciseTemplate with selected exercise
                } label: {
                    Text("Replace")
                        .foregroundStyle(primaryColor)
                }
                
                
                Button {
                    dismiss()
                    exerciseInRoutineViewModel.deleteExerciseInRoutine(exerciseInRoutine)
                } label: {
                    Text("Delete")
                        .foregroundStyle(.red)
                }
                
            }
        }
        .navigationTitle(exerciseInRoutine.exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        //MARK: Sheets
        .sheet(isPresented: $replaceExerciseInRoutine) {
            NavigationStack {
                SelectCategoryView(
                    isSelectingExercise: $replaceExerciseInRoutine,
                    onExerciseSelected: {exerciseTemplate in
                        //take the selected exerciseTemplate and swap it for the existing exerciseTemplate
                        exerciseInRoutineViewModel.updateExerciseInRoutine(exerciseInRoutine, newExerciseTemplate: exerciseTemplate)
                        //dismiss
                        print(exerciseTemplate.name)
                        print(exerciseInRoutine.exerciseName)
                        replaceExerciseInRoutine = false
                    }
                )
            }
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
        
    }
}
