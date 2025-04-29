import SwiftData
import SwiftUI

func initializeDefaultThemes(in modelContext: ModelContext) {
    let fetchRequest = FetchDescriptor<UserTheme>(sortBy: [])
    
    if let existingThemes = try? modelContext.fetch(fetchRequest), !existingThemes.isEmpty {
        if !existingThemes.contains(where: { $0.isSelected }) {
            if let defaultTheme = existingThemes.first(where: { $0.name == "Ocean Blue" }) {
                defaultTheme.isSelected = true
                try? modelContext.save()
            }
        }
        return
    }

    let defaultThemes: [UserTheme] = [
        {
            let theme = UserTheme(name: "Ocean Blue",
                                  lightModeHex: "#2980b9",  // light blue
                                  darkModeHex: "#1B4F72")   // deep navy
            theme.isSelected = true
            return theme
        }(),
        UserTheme(name: "Sunset Orange",
                  lightModeHex: "#e67e22",  // bright orange
                  darkModeHex: "#A04000"),  // burnt orange
        UserTheme(name: "Forest Green",
                  lightModeHex: "#27ae60",  // fresh green
                  darkModeHex: "#145A32"),  // dark forest
        UserTheme(name: "Lilac Purple",
                  lightModeHex: "#9b59b6",  // pastel purple
                  darkModeHex: "#512E5F"),  // plum
        UserTheme(name: "Steel Gray",
                  lightModeHex: "#7f8c8d",  // soft gray
                  darkModeHex: "#2C3E50"),  // slate gray
        UserTheme(name: "Blush Pink",
                  lightModeHex: "#f78fb3",  // blush pink
                  darkModeHex: "#833471"),  // muted purple
        UserTheme(name: "Sky Teal",
                  lightModeHex: "#1abc9c",  // minty teal
                  darkModeHex: "#0E6251"),  // deep teal
        UserTheme(name: "Amber Gold",
                  lightModeHex: "#f1c40f",  // bold yellow
                  darkModeHex: "#7D6608"),  // golden bronze
        UserTheme(name: "Coral Red",
                  lightModeHex: "#ff6b6b",  // bright coral
                  darkModeHex: "#922B21"),  // rich burgundy
        UserTheme(name: "Slate Indigo",
                  lightModeHex: "#5D6D7E",  // dusty blue-gray
                  darkModeHex: "#283747")   // deep indigo
    ]

    for theme in defaultThemes {
        try? modelContext.insert(theme)
    }
    
    try? modelContext.save()
}
