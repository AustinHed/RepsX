//
//  SettingsView.swift
//  RepsX
//
//  Created by Austin Hed on 3/2/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack{
            List{
                Section("Personalization"){
                    NavigationLink("Themes") {
                        //tos
                    }
                    
                    NavigationLink("App Icon") {
                        //tos
                    }
                }
                
                //exercises and categories
                Section("Exercises and Categories"){
                    
                    NavigationLink("Edit Exercises") {
                        //tos
                    }
                    NavigationLink("Edit Categories") {
                        //tos
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
        }
    }
}

#Preview {
    SettingsView()
}
