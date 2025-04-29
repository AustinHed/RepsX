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
                                          lightModeHex: "#007AFF",
                                          darkModeHex: "#8E8E93"
        )
    }
    
    //modelContext
    @Environment(\.modelContext) private var modelContext
    
    //View Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    @State private var customColor: Color = .gray
    @State private var showColorPicker: Bool = false
        
    var body: some View {
            List{
                //theme options
                ForEach(userThemes.filter {$0.name != "Custom Theme"}) { userTheme in
                    Button {
                        userThemeViewModel.selectCurrentTheme(userTheme)
                    } label: {
                        HStack{
                            if userTheme.isSelected {
                                HStack{
                                    Text(userTheme.name)
                                        .foregroundStyle(Color.primary)
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hexString: userTheme.lightModeHex))
                                }
                            } else {
                                Text(userTheme.name)
                                    .foregroundStyle(Color.primary)
                            }
                            
                            Spacer()
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.lightModeHex))
                                .padding(.trailing, 5)
                            
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.darkModeHex))
                                .padding(.trailing, 5)
                            
                        }
                    }
                }
                
                //Custom theme
                Section {
                    ForEach(userThemes.filter {$0.name == "Custom Theme"}) { userTheme in
                        Button {
                            userThemeViewModel.selectCurrentTheme(userTheme)
                        } label: {
                            HStack{
                                if userTheme.isSelected {
                                    HStack{
                                        Text(userTheme.name)
                                            .foregroundStyle(Color.primary)
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color(hexString: userTheme.lightModeHex))
                                    }
                                } else {
                                    Text(userTheme.name)
                                        .foregroundStyle(Color.primary)
                                }
                                
                                Spacer()
                                ColorPicker("", selection: $customColor, supportsOpacity: false)
                                    .labelsHidden()
                                    .onChange(of: customColor) { newColor in
                                        userTheme.lightModeHex = newColor.toHex() ?? userTheme.lightModeHex
                                        userTheme.darkModeHex = newColor.darkerVariantHex() ?? userTheme.darkModeHex
                                        try? modelContext.save()
                                    }
                                    .onAppear {
                                        customColor = Color(hexString: userTheme.lightModeHex)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Theme")
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: userThemeViewModel.primaryColor)
            )
            .safeAreaInset(edge: .bottom) {
                // Add extra space (e.g., 100 points)
                Color.clear.frame(height: 100)
            }
            
        .tint(userThemeViewModel.primaryColor)
    }
}

#Preview {
    SelectThemeView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self, ExerciseInRoutine.self, UserTheme.self])
}








