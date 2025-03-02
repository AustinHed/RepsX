//
//  EditRoutine.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import UIKit

struct EditRoutine: View {
    
    
    //the routine to edit
    var routine: Routine
    
    //model context
    @Environment(\.modelContext) private var modelContext
    //workout view model
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    //routine view model
    private var routineViewModel: RoutineViewModel {
        RoutineViewModel(modelContext: modelContext)
    }
    
    //show color picker
    @State var toggleColorPicker: Bool = false
    
    //defaults to gray, unless there is already an incoming value
    @State var selectedColor:String = "#808080"
    
    var body: some View {
        NavigationStack{
            List {
                //start button
                Section {
                    Button("Start Workout"){
                        //start workout, insert new workout instance
                    }.bold()
                }
                
                Section{
                    
                    //Edit Name
                    TextField("Name this Routine", text: Binding(
                        get: {routine.name},
                        set: { newName in
                            if newName.isEmpty {
                                routine.name = ""
                            } else {
                                routine.name = newName
                            }
                        }
                    ))
                    .onSubmit{
                        routineViewModel.updateRoutine(routine, newName: routine.name)
                    }
                    
                    //Edit Color
                    Button {
                        toggleColorPicker = true
                    } label: {
                        HStack {
                            Text("Change Routine Color")
                                .foregroundStyle(Color(UIColor(hex:selectedColor) ?? .gray))
                            Spacer()
                            Circle()
                                .foregroundStyle(Color(UIColor(hex:selectedColor) ?? .gray))
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                }
                
                //exercises
                Section{
                    ForEach(routine.exercises, id: \.self) { exercise in
                        Button {
                            //edit the given ExerciseInRoutine
                        } label: {
                            VStack(alignment:.leading){
                                Text(exercise.exerciseName)
                                    .foregroundStyle(.black)
                                Text("\(exercise.setCount) Sets")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    
                            }
                        }
                    }
                }
                
                //add exercise button
                Section{
                    Button {
                        //add a new ExerciseInRoutine
                        //open the ExerciseInRoutine view
                    } label: {
                        Text("Add Exercise")
                    }

                }
                
            }
            .navigationTitle(routine.name == "" ? "New Routine" : routine.name)
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        //favorite routine
                        Button (role: routine.favorite ? .destructive : nil){
                            routineViewModel.favoriteRoutine(routine)
                            print(routine.favorite)
                        } label: {
                            
                            HStack{
                                Text(routine.favorite ? "Unfavorite" : "Favorite")
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "star.fill")
                            }
                        }
                        
                        //reorder exercises
                        Button {
                            //reorder
                        } label: {
                            HStack{
                                Text("Reorder")
                                Spacer()
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                        
                        //delete specific routine
                        Button (role:.destructive) {
                            //delete
                        } label: {
                            HStack{
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    
                }
            }
            //MARK: Sheets
            .sheet(isPresented: $toggleColorPicker) {
                ColorPickerGrid(selectedColor: selectedColor) { color in
                    selectedColor = color
                    routineViewModel.updateRoutine(routine, newColor: color)
                }
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
            }
        }
        .onAppear {
            if routine.colorHex != nil {
                selectedColor = routine.colorHex!
            }
        }
        
    }
}

#Preview {
    let eTemplate = ExerciseTemplate(name: "Bench Press", category:CategoryModel(name: "category"), modality: .repetition)
    
    let template = ExerciseInRoutine(exerciseTemplate:eTemplate,setCount:5)
    
    let routine2 = Routine(name: "Push Day", colorHex: "#808080", exercises: [template])
    
    EditRoutine(routine: routine2)
}
