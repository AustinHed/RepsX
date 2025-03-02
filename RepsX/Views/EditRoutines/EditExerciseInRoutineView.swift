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
                                    exerciseInRoutineViewModel.updateSetCount(exerciseInRoutine, newSetCount: Int(newValue))
                                }
                            }
                            
                    }
                    
                }
                
                Section{
                    
                    Button {
                        //replace
                    } label: {
                        Text("Replace")
                            .foregroundStyle(.secondary)
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
        }
        
    }
}

#Preview {
    let categoryModel = CategoryModel(name: "chest")
    let exerciseTemplate = ExerciseTemplate(id: UUID(), name: "Test Exercise", category: categoryModel, modality: .repetition, hidden: false)
    let exerciseInRoutine = ExerciseInRoutine(exerciseTemplate: exerciseTemplate, setCount: 3)
    EditExerciseInRoutineView(exerciseInRoutine: exerciseInRoutine)
}
