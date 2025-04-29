//
//  EditExerciseTemplateView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import SwiftData

struct EditExerciseTemplateView: View {
    
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
                //update name
                Section("Name"){
                    if exerciseTemplate.standard {
                        Text(exerciseTemplate.name)
                            .foregroundStyle(Color.primary)
                    } else {
                        TextField("Exercise", text: $exerciseTemplate.name)
                            .onSubmit {
                                exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newName: exerciseTemplate.name)
                            }
                            .foregroundStyle(Color.primary)
                    }
                }

                //update category
                Section("Category"){
                    if exerciseTemplate.standard {
                        Text(exerciseTemplate.category.name)
                    } else {
                        NavigationLink(exerciseTemplate.category.name) {
                            ChooseNewCategoryView(exerciseTemplate: exerciseTemplate)
                        }
                    }
                    
                }
                
                //choose modality section
                Section {
                    if exerciseTemplate.standard {
                        VStack (alignment: .leading){
                            Text(exerciseTemplate.modality.rawValue.capitalizingFirstLetter())
                            modalityDetail
                        }
                    } else {
                        NavigationLink {
                            ChooseNewModalityView(exerciseTemplate: exerciseTemplate)
                        } label: {
                            VStack (alignment: .leading){
                                Text(exerciseTemplate.modality.rawValue.capitalizingFirstLetter())
                                modalityDetail
                            }
                        }
                    }
                    
                } header: {
                    Text("Modality")
                } footer: {
                    Text("How an exercise is performed, and how measures are used to track performance (Weight, Reps, Time)")
                }
                
                //delete button
                Section() {
                    Button("Delete"){
                        exerciseTemplateViewModel.deleteExerciseTemplate(exerciseTemplate)
                        dismiss()
                    }
                    .foregroundStyle(.red)
                    .disabled(exerciseTemplate.standard)
                }
            }
            .navigationTitle(Text("Edit Exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            //MARK: Toolbar
            .toolbar {
                //Back button
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
}


//MARK: Modality options
extension EditExerciseTemplateView {
    private var modalityDetail: some View {
        switch exerciseTemplate.modality {
        case .repetition:
            return Text("Weight, Reps")
                .font(.caption)
                .foregroundColor(.secondary)
        case .endurance:
            return Text("Distance, Time")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

