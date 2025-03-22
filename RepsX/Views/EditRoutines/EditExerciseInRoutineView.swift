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
    @Environment(\.themeColor) var themeColor
    
    //the ExerciseInRoutine to edit
    @State var exerciseInRoutine: ExerciseInRoutine
    
    //viewModel
    private var exerciseInRoutineViewModel:ExerciseInRoutineViewModel {
        ExerciseInRoutineViewModel(modelContext: modelContext)
    }

    
    //replace exercise var
    @State var replaceExerciseInRoutine:Bool = false
    
    var body: some View {
        NavigationStack{
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
                            .foregroundStyle(themeColor)
                    }

                    
                    Button {
                        exerciseInRoutineViewModel.deleteExerciseInRoutine(exerciseInRoutine)
                        dismiss()
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
                ZStack{
                    themeColor.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    WavyBackground(startPoint: 50,
                                   endPoint: 120,
                                   point1x: 0.6,
                                   point1y: 0.1,
                                   point2x: 0.4,
                                   point2y: 0.015,
                                   color: themeColor.opacity(0.1)
                    )
                        .edgesIgnoringSafeArea(.all)
                    WavyBackground(startPoint: 120,
                                   endPoint: 50,
                                   point1x: 0.4,
                                   point1y: 0.01,
                                   point2x: 0.6,
                                   point2y: 0.25,
                                   color: themeColor.opacity(0.1)
                    )
                        .edgesIgnoringSafeArea(.all)
                }
            )
        }
        
    }
}

#Preview {
    let categoryModel = CategoryModel(name: "chest")
    let exerciseTemplate = ExerciseTemplate(id: UUID(), name: "Test Exercise", category: categoryModel, modality: .repetition, hidden: false)
    let exerciseInRoutine = ExerciseInRoutine(exerciseTemplate: exerciseTemplate, setCount: 3)
    EditExerciseInRoutineView(exerciseInRoutine: exerciseInRoutine)
}
