//
//  SelectThemeView.swift
//  RepsX
//
//  Created by Austin Hed on 3/4/25.
//

import SwiftUI
import SwiftData

struct SelectThemeView: View {
    
    //MARK: Query
    @Query(sort: \UserTheme.name) var userThemes: [UserTheme]
    @Query(filter: #Predicate<UserTheme> { $0.isSelected }) var selectedThemes: [UserTheme]
    
    var selectedTheme: UserTheme {
        selectedThemes.first ?? UserTheme(name: "Default Theme",
                                          primaryHex: "#007AFF",
                                          secondaryHex: "#8E8E93"
        )
    }
    
    @Binding var path: NavigationPath
    
    //modelContext
    @Environment(\.modelContext) private var modelContext
    
    //View Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
        
    var body: some View {
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
                CustomBackground(themeColor: userThemeViewModel.primaryColor)
            )
            
        .tint(userThemeViewModel.primaryColor)
    }
}

//#Preview {
//    SelectThemeView()
//        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self, ExerciseInRoutine.self, UserTheme.self])
//}







