import SwiftData
import SwiftUI

func initializeDefaultThemes(in modelContext: ModelContext) {
    // Create a fetch request to check for existing themes.
    let fetchRequest = FetchDescriptor<UserTheme>(sortBy: [])
    
    // Attempt to fetch the themes.
    if let existingThemes = try? modelContext.fetch(fetchRequest), !existingThemes.isEmpty {
        // If themes exist, check if any theme is selected.
        if !existingThemes.contains(where: { $0.isSelected }) {
            // If none is selected, mark the Deep Sea Blue theme as selected if it exists.
            if let blueTheme = existingThemes.first(where: { $0.name == "Deep Sea Blue" }) {
                blueTheme.isSelected = true
                try? modelContext.save()
            }
        }
        return
    }
    
    // No themes exist, so define your pre-defined flat, modern themes with complementary secondary colors.
    let defaultThemes: [UserTheme] = [
        // Deep Sea Blue theme (selected by default)
        {
            // Primary: Bold deep blue; Secondary: Light, warm orange (complementary to blue)
            let theme = UserTheme(name: "Deep Sea Blue", primaryHex: "#2980b9", secondaryHex: "#F5C464")
            theme.isSelected = true
            return theme
        }(),
        // Crimson Flame theme
        // Primary: Intense red; Secondary: Light mint green (complementary to red)
        UserTheme(name: "Crimson Flame", primaryHex: "#c0392b", secondaryHex: "#7bed9f"),
        // Royal Amethyst theme
        // Primary: Rich purple; Secondary: Soft pastel yellow (complementary to purple)
        UserTheme(name: "Royal Amethyst", primaryHex: "#8e44ad", secondaryHex: "#f9e79f"),
        // Emerald Forest theme
        // Primary: Deep green; Secondary: Gentle coral pink (complementary to green)
        UserTheme(name: "Emerald Forest", primaryHex: "#27ae60", secondaryHex: "#f5b7b1"),
        // Tangerine Burst theme
        // Primary: Vibrant orange; Secondary: Light blue (complementary to orange)
        UserTheme(name: "Tangerine Burst", primaryHex: "#d35400", secondaryHex: "#85c1e9"),
        // Tropical Teal theme
        // Primary: Bold teal; Secondary: Soft peach (complementary to teal’s blue-green)
        UserTheme(name: "Tropical Teal", primaryHex: "#16a085", secondaryHex: "#f5b041"),
        // Urban Slate theme
        // Primary: Modern dark gray; Secondary: Warm beige (a gentle contrast for neutral slate)
        UserTheme(name: "Urban Slate", primaryHex: "#7f8c8d", secondaryHex: "#f5e6cc"),
        // Mocha Bronze theme
        // Primary: Earthy brown; Secondary: Light blue (complementary to brown)
        UserTheme(name: "Mocha Bronze", primaryHex: "#8e6e53", secondaryHex: "#7fb3d5"),
        // American Patriot theme
        // Primary: Patriotic red; Secondary: Soothing turquoise (complementary to red)
        UserTheme(name: "American Patriot", primaryHex: "#B22234", secondaryHex: "#48c9b0"),
        // iOS Classic Blue theme
        // Primary: Standard iOS blue; Secondary: Soft peach (complementary to blue)
        UserTheme(name: "iOS Classic Blue", primaryHex: "#007AFF", secondaryHex: "#ffcc80")
    ]
    
    // Insert each default theme into the model context.
    for theme in defaultThemes {
        try? modelContext.insert(theme)
    }
    
    // Save the changes to persist the new themes.
    try? modelContext.save()
}
