
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
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var body: some View {
        
        List{
            
            if !filteredStandardExercises.isEmpty{
                Section(header:
                            HStack{
                    Text("Default Exercises")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ) {
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
                Section(header:
                            HStack{
                    Text("Custom Exercises")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ) {
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
            CustomBackground(primaryColor: primaryColor)
        )
    }
}
