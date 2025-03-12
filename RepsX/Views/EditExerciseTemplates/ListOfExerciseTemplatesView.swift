//
//  ListOfExerciseTemplatesView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import SwiftData

struct ListOfExerciseTemplatesView<Destination: View>: View {
    
    //Fetch ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{
        exerciseTemplate in exerciseTemplate.hidden == false}, sort: \ExerciseTemplate.name) var exercises: [ExerciseTemplate]
    @Environment(\.modelContext) private var modelContext
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    //View Model
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme view Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //Add new category
    @State private var isAddingNewExercise: Bool = false
    
    //the nav title, dependent on how this view is being accessed
    let navigationTitle:String
    
    //optionally passing throug a list of Workouts
    let allWorkouts: [Workout]?
    
    // This closure builds the destination view for a given exercise.
    let destinationBuilder: (ExerciseTemplate) -> Destination
    
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { exercise in
                    NavigationLink(exercise.name) {
                        //EditExerciseTemplateView(exerciseTemplate: exercise)
                        destinationBuilder(exercise)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar{
                //add new exercise
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingNewExercise.toggle()
                    } label: {
                        Image(systemName:"plus.circle")
                        
                    }
                    .foregroundStyle(userThemeViewModel.primaryColor)

                }
            }
            //MARK: Sheets
            //add new exercise
            .sheet(isPresented: $isAddingNewExercise) {
                AddNewExerciseTemplateView()
            }
        }
    }
}

//#Preview {
//    ListOfExerciseTemplatesView()
//}
