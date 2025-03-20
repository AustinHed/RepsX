//
//  ChooseNewModalityView.swift
//  RepsX
//
//  Created by Austin Hed on 3/19/25.
//

import SwiftUI
import SwiftData

struct ChooseNewModalityView: View {
    
    //the exercise template to edit
    @State var exerciseTemplate: ExerciseTemplate
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
        
    
    var body: some View {
        
        NavigationStack{
            
            List{
                
                //Reps
                Section{
                    Button {
                        //update
                        exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newModality: .repetition)
                        //dismiss
                        dismiss()
                    } label: {
                        //show the checkmark if already selected
                        modalityLabel(for: .repetition)
                    }

                }  footer: {
                    Text("For exercises measured in Weight and Reps \nex. Bench Press, Squats, Deadlift, etc.")
                }
                //Tension
                Section {
                    Button {
                        exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newModality: .tension)
                        dismiss()
                    } label: {
                        modalityLabel(for: .tension)
                    }
                    
                } footer: {
                    Text("For exercises measured in Weight and Time \nex. Wallsits, Weighted Plank, etc.")
                }
                
                //Endurance
                Section {
                    Button {
                        exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newModality: .endurance)
                        dismiss()
                    } label: {
                        modalityLabel(for: .endurance)
                    }
                } footer: {
                    Text("For exercises measured in Distance and Time \nex. Running, Rowing, Cycling, etc.")
                }
                
                //Other
                Section {
                    Button {
                        exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newModality: .other)
                        dismiss()
                    } label: {
                        modalityLabel(for: .other)
                    }
                }  footer: {
                    Text("For exercises not measured as the above \nex. Yoga, Pilates, etc. ")
                }
                  
            }
            .navigationTitle("Choose modality")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    //MARK: this is what i should use to add the checkmark
    @ViewBuilder
    private func modalityLabel(for modality: ExerciseModality) -> some View {
        if exerciseTemplate.modality == modality {
            HStack {
                Text(modality.rawValue.capitalizingFirstLetter())
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        } else {
            Text(modality.rawValue.capitalizingFirstLetter())
                .foregroundStyle(.black)
        }
    }
    
}
