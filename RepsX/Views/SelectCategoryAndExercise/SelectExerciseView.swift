
//  SelectExerciseView.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.


import SwiftUI
import SwiftData
import Foundation

struct SelectExerciseView: View {
    
    //takes selected category
    let category: CategoryModel
    
    //the dismiss
    @Binding var isSelectingExercise: Bool
    
    //Adding an exercise
    @State var isAddingExercise: Bool = false
    
    //the passable onSelect
    var onExerciseSelected:(ExerciseTemplate) -> Void
    
    // Fetch standard ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{ exerciseTemplate in
        exerciseTemplate.standard == true
    }, sort: \ExerciseTemplate.name)
    var standardExercises: [ExerciseTemplate]
    
    //fetch custom ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{ exerciseTemplate in
        exerciseTemplate.standard == false &&
        exerciseTemplate.hidden == false
    }, sort: \ExerciseTemplate.name)
    var customExercises: [ExerciseTemplate]
    
    var filteredStandardExercises: [ExerciseTemplate] {
        standardExercises.filter { $0.category.id == category.id }
    }
    
    var filteredCustomExercises: [ExerciseTemplate] {
        customExercises.filter { $0.category.id == category.id }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        List{
            
            Section("Standard Exercises") {
                ForEach(filteredStandardExercises) { exercise in
                    Button {
                        onExerciseSelected(exercise)
                        isSelectingExercise = false
                    } label: {
                        HStack{
                            Text(exercise.name)
                        }
                        .foregroundStyle(.black)
                        
                    }
                }
            }
            
            if !filteredCustomExercises.isEmpty{
                Section("Custom Exercises") {
                    ForEach(filteredCustomExercises) { exercise in
                        Button {
                            onExerciseSelected(exercise)
                            isSelectingExercise = false
                        } label: {
                            HStack{
                                Text(exercise.name)
                            }
                            .foregroundStyle(.black)
                        }
                    }
                }
            }
            
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        //MARK: Toolbar
        .toolbar {
            // Back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            //add exercise
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    //action - open the "add Exercise" view
                    isAddingExercise.toggle()
                    
                } label: {
                    Image(systemName:"plus.circle")
                }
            }
        }
        //MARK: Sheets
        .sheet(isPresented: $isAddingExercise) {
            AddNewExerciseTemplateView(category: category)
        }
    }
}
