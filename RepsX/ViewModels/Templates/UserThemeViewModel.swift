//
//  UserThemeViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 3/4/25.
//

import SwiftData
import SwiftUI

@Observable
class UserThemeViewModel {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //add
    func addUserTheme(name: String, primaryHex: String, secondaryHex: String) {
        let newUserTheme = UserTheme(name: name, primaryHex: primaryHex, secondaryHex: secondaryHex)
        modelContext.insert(newUserTheme)
    }
    
    //delete
    func deleteUserTheme(_ userTheme: UserTheme) {
        //first, delete theme
        modelContext.delete(userTheme)
        //then, save
        save()
    }
    
    //update
    func updateUserTheme(_ userTheme: UserTheme, newName:String? = nil) {
        if let newName = newName {
            userTheme.name = newName
        }
        save()
    }
    
    //mark as current theme
    func selectCurrentTheme(_ userTheme: UserTheme) {
        let themes = fetchThemes( )
        for theme in themes {
            theme.isSelected = (theme.id == userTheme.id)
        }
        
        save()
    }
    
    //fetch
    func fetchThemes() -> [UserTheme] {
        let descriptor = FetchDescriptor<UserTheme>(sortBy: [SortDescriptor(\.name, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching UserThemes: \(error)")
            return []
        }
    }
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving UserThemes: \(error.localizedDescription)")
        }
    }
    
    
}
