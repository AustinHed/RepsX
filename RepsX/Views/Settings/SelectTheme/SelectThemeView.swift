//
//  SelectThemeView.swift
//  RepsX
//
//  Created by Austin Hed on 3/4/25.
//

import SwiftUI
import SwiftData

struct SelectThemeView: View {
    
    //Fetch all themes
    @Query(sort: \UserTheme.name) var userThemes: [UserTheme]
    //fetch selected theme
    @Query(filter: #Predicate<UserTheme> { $0.isSelected }) var selectedThemes: [UserTheme]
    var selectedTheme: UserTheme {
        selectedThemes.first ?? UserTheme(name: "Default Theme",
                                          primaryHex: "#007AFF",
                                          secondaryHex: "#8E8E93"
        )
    }
    
    //modelContext
    @Environment(\.modelContext) private var modelContext
    
    //View Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    //access the themes
    
    
    var body: some View {
        NavigationStack{
            List{
                //theme options
                ForEach(userThemes) { userTheme in
                    Button {
                        userThemeViewModel.selectCurrentTheme(userTheme)
                    } label: {
                        HStack{
                            if userTheme.isSelected {
                                HStack{
                                    Text(userTheme.name)
                                        .foregroundStyle(.black)
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hexString: userTheme.primaryHex))
                                }
                            } else {
                                Text(userTheme.name)
                                    .foregroundStyle(.black)
                            }
                            
                            Spacer()
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.primaryHex))
                                .padding(.trailing, 5)
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.secondaryHex))
                        }
                    }
                }
                
                Section {
                    Button {
                        //no action yet - allow custom theme
                    } label: {
                        Text("Custom Theme")
                    }

                }
            }
            .navigationTitle("Select Theme")
            //Background
            .scrollContentBackground(.hidden)
            .background(
                ZStack{
                    userThemeViewModel.primaryColor.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    WavyBackground(startPoint: 50,
                                   endPoint: 120,
                                   point1x: 0.6,
                                   point1y: 0.1,
                                   point2x: 0.4,
                                   point2y: 0.015,
                                   color: userThemeViewModel.primaryColor.opacity(0.1)
                    )
                        .edgesIgnoringSafeArea(.all)
                    WavyBackground(startPoint: 120,
                                   endPoint: 50,
                                   point1x: 0.4,
                                   point1y: 0.01,
                                   point2x: 0.6,
                                   point2y: 0.25,
                                   color: userThemeViewModel.primaryColor.opacity(0.1)
                    )
                        .edgesIgnoringSafeArea(.all)
                }
            )
            
        }
        .tint(userThemeViewModel.primaryColor)
    }
}

#Preview {
    SelectThemeView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self, ExerciseInRoutine.self, UserTheme.self])
}







