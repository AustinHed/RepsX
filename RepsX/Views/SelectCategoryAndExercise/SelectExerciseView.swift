
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
    //only show exercises that match the given category
    var filteredStandardExercises: [ExerciseTemplate] {
        standardExercises.filter { $0.category.id == category.id }
    }
    //fetch custom ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{ exerciseTemplate in
        exerciseTemplate.standard == false &&
        exerciseTemplate.hidden == false
    }, sort: \ExerciseTemplate.name)
    var customExercises: [ExerciseTemplate]
    //only show exercises that match the given category
    var filteredCustomExercises: [ExerciseTemplate] {
        customExercises.filter { $0.category.id == category.id }
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    var body: some View {
        
        List{
            
            if !filteredStandardExercises.isEmpty{
                Section("Default Exercises") {
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
