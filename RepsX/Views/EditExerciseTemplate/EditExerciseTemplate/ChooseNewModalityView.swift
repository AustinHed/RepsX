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
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
        
    
    var body: some View {
        
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
                  
            }
            .navigationTitle("Choose modality")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
        
    }
    
    //MARK: Add checkmark
    @ViewBuilder
    private func modalityLabel(for modality: ExerciseModality) -> some View {
        if exerciseTemplate.modality == modality {
            HStack {
                Text(modality.rawValue.capitalizingFirstLetter())
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(primaryColor)
            }
        } else {
            Text(modality.rawValue.capitalizingFirstLetter())
                .foregroundStyle(Color.primary)
        }
    }
    
}
