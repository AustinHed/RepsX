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
    
    //model context
    @Environment(\.modelContext) private var modelContext
    
    private var exerciseTemplateViewModel:ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack{
            List{
                //update name
                Section("Name"){
                    TextField("Exercise", text: $exerciseTemplate.name)
                        .onSubmit {
                            exerciseTemplateViewModel.updateExerciseTemplate(exerciseTemplate, newName: exerciseTemplate.name)
                        }
                        .foregroundStyle(.black)
                    
                }
                
                //update category
                Section("Category"){
                    NavigationLink(exerciseTemplate.category.name) {
                        ChooseNewCategoryView( exerciseTemplate: exerciseTemplate)
                    }
                }
                
                //choose modality section
                Section {
                    NavigationLink {
                        ChooseNewModalityView(exerciseTemplate: exerciseTemplate)
                    } label: {
                        VStack (alignment: .leading){
                            Text(exerciseTemplate.modality.rawValue.capitalizingFirstLetter())
                            modalityDetail
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
        }
        
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
        case .tension:
            return Text("Weight, Time")
                .font(.caption)
                .foregroundColor(.secondary)
        case .endurance:
            return Text("Distance, Time")
                .font(.caption)
                .foregroundColor(.secondary)
        case .other:
            return Text("Other")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

//#Preview {
//    let exerciseTemplate = ExerciseTemplate(name: "Test")
//    EditExerciseTemplateView(exerciseTemplate: exerciseTemplate)
//}
