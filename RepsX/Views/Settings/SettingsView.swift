//
//  SettingsView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    //theme color
    @Environment(\.themeColor) var themeColor
    
    @Binding var selectedTab: MainTabbedView.TabOptions
    var body: some View {
        NavigationStack{
            List{
                Section("Personalization"){
                    NavigationLink("Themes") {
                        SelectThemeView()
                    }
                    
                    NavigationLink("App Icon") {
                        //tos
                    }
                }
                
                //exercises and categories
                Section("Exercises and Categories"){
                    
                    
                    NavigationLink("Edit Exercises") {
                        ListOfExerciseTemplatesView(navigationTitle: "Edit Exercises", destinationBuilder: { exercise in
                            EditExerciseTemplateView(exerciseTemplate: exercise)
                        })
                    }
                    
                    NavigationLink("Edit Categories") {
                        ListOfCategoriesView(navigationTitle: "Edit Categories", destinationBuilder: { category in
                            EditCategoryView(category: category)
                        })
                    }
                    
                }
                
                //feedback and support
                Section("Feedback and Support"){
                    NavigationLink("Submit Feedback") {
                        //tos
                    }
                    NavigationLink("Help and Support") {
                        //tos
                    }
                    
                    NavigationLink("Acknowledgements") {
                        //tos
                    }
                    
                }
                
                //legal
                Section("Legal"){
                    NavigationLink("Terms of Service") {
                        //tos
                    }
                    NavigationLink("Privacy Policy") {
                        //tos
                    }
                }
            }
            .navigationTitle("Settings")
            //Background
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
        .onAppear{
            initializeDefaultThemes(in: modelContext)
        }
        .tint(themeColor)
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.settings))
}
