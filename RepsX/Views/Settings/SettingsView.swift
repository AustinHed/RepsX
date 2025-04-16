import SwiftUI
import SwiftData
import UIKit
// Define a new destination type for Settings
enum SettingsDestination: Hashable {
    case theme
    case appIcon //todo
    
    case exercises
    case categories
    
    case feedback
    case help
    case acknowledgements
    
    case terms
    case privacy
    
}

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    var body: some View {
        List {
            //Personalization
            Section("Personalization") {
                NavigationLink("Themes", value: SettingsDestination.theme)
                NavigationLink("App Icon", value: SettingsDestination.appIcon)
            }
            
            
            //Exercise and Categories
            Section("Exercises and Categories") {
                NavigationLink("Edit Exercises", value: SettingsDestination.exercises)
                NavigationLink("Edit Categories", value: SettingsDestination.categories)
            }
            
            Section("Feedback and Support") {
                NavigationLink("Submit Feedback", value: SettingsDestination.feedback)
                Button {
                    if let url = URL(string: "itms-apps://itunes.apple.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack{
                        Text("Rate on the App Store")
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName:"chevron.right")
                            .foregroundStyle(.gray).opacity(0.5)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                }
                NavigationLink("Acknowledgements") {
                    // to be implemented
                }
            }
            
            Section("Legal") {
                NavigationLink("Terms of Service", value: SettingsDestination.terms)
                NavigationLink("Privacy Policy", value: SettingsDestination.privacy)
            }
            
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(CustomBackground(themeColor: themeColor))
        //MARK: Navigation Destinations
        .navigationDestination(for: SettingsDestination.self) { destination in
            switch destination {
            case .theme:
                SelectThemeView()
            case .appIcon:
//                Text("App Icon View") // Replace with your actual App Icon view.
                SelectAppIconView()
            case .exercises:
                ListOfExerciseTemplatesView(navigationTitle: "Edit Exercises") { exercise in
                    EditExerciseTemplateView(exerciseTemplate: exercise)
                }
            case .categories:
                ListOfCategoriesView(navigationTitle: "Edit Categories") { category in
                    EditCategoryView(category: category)
                }
            case .feedback:
                SubmitFeedbackView()
            case .help:
                Text("Help and Support View")
            case .acknowledgements:
                Text("Acknowledgements View")
            case .terms:
                TermsOfServiceView()
            case .privacy:
                PrivacyPolicyView()
            }
        }
        //MARK: Other
        .navigationTitle("Settings")
        .onAppear {
            initializeDefaultThemes(in: modelContext)
        }
        .tint(themeColor)
        .contentMargins(.horizontal,16)
    }
}

#Preview {
    NavigationStack{
        SettingsView()
    }
    
}
