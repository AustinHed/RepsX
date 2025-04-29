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
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var body: some View {
        List {
            //Personalization
            Section(header:
                        HStack{
                Text("Personalization")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ) {
                NavigationLink("Themes", value: SettingsDestination.theme)
                NavigationLink("App Icon", value: SettingsDestination.appIcon)
            }
            
            
            //Exercise and Categories
            Section(header:
                        HStack{
                Text("Exercises & Categories")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ) {
                NavigationLink("Edit Exercises", value: SettingsDestination.exercises)
                NavigationLink("Edit Categories", value: SettingsDestination.categories)
            }
            
            Section(header:
                        HStack{
                Text("Feedback & Support")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ) {
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
            
            Section(header:
                        HStack{
                Text("Legal")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            ) {
                NavigationLink("Terms of Service", value: SettingsDestination.terms)
                NavigationLink("Privacy Policy", value: SettingsDestination.privacy)
            }
            
        }
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(CustomBackground(primaryColor: primaryColor))
        
        //MARK: Navigation Destinations
        .navigationDestination(for: SettingsDestination.self) { destination in
            switch destination {
            case .theme:
                SelectThemeView()
            case .appIcon:
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
        .tint(primaryColor)
        //.contentMargins(.horizontal,16)
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
    }
}

#Preview {
    NavigationStack{
        SettingsView()
    }
    
}
