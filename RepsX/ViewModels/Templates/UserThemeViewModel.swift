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
    func addUserTheme(name: String, lightModeHex: String, darkModeHex: String) {
        let newUserTheme = UserTheme(name: name, lightModeHex: lightModeHex, darkModeHex: darkModeHex)
        modelContext.insert(newUserTheme)
        save()
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
    
    //computed selected theme
    var selectedTheme: UserTheme {
        fetchThemes().first(where: { $0.isSelected }) ?? UserTheme(
            name: "Default Theme",
            lightModeHex: "#007AFF",
            darkModeHex: "#8E8E93",
            isSelected: true
        )
    }
    
    var primaryColor: Color {
        let theme = fetchThemes().first(where: { $0.isSelected }) ?? UserTheme(
            name: "Default Theme",
            lightModeHex: "#007AFF",
            darkModeHex: "#8E8E93",
            isSelected: true
        )
        return Color(hexString: theme.lightModeHex)
    }
    
    var secondaryColor: Color {
        let theme = fetchThemes().first(where: { $0.isSelected }) ?? UserTheme(
            name: "Default Theme",
            lightModeHex: "#007AFF",
            darkModeHex: "#8E8E93",
            isSelected: true
        )
        return Color(hexString: theme.darkModeHex)
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

@Observable
final class ThemeManager {
    var userThemes: [UserTheme] = []
    var selectedTheme: UserTheme = UserTheme(name: "Default Theme",
                                              lightModeHex: "#007AFF", //#007AFF
                                             darkModeHex: "#8E8E93") //#8E8E93
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshThemes()
    }
    
    // Computed property for easier access to the primaryHex value
    var primaryHex: String {
        selectedTheme.lightModeHex
    }
    
    // Computed property for easier access to the secondaryHex value
    var secondaryHex: String {
        selectedTheme.darkModeHex
    }
    
    func refreshThemes() {
        let descriptor = FetchDescriptor<UserTheme>(sortBy: [SortDescriptor(\.name)])
        if let themes = try? modelContext.fetch(descriptor), !themes.isEmpty {
            userThemes = themes
            if let current = themes.first(where: { $0.isSelected }) {
                selectedTheme = current
            }
        }
    }
    
    func selectTheme(_ theme: UserTheme) {
        for t in userThemes {
            t.isSelected = (t.id == theme.id)
        }
        try? modelContext.save()
        refreshThemes() // Refresh after saving changes
    }
}


