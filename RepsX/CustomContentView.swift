import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var selectedTab: Tab = .history
    
    @Environment(\.modelContext) private var modelContext
    
    //This hides the bar at the bottom of the screen
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    //enum of tabs
    enum Tab: CaseIterable {
        case history, routines, stats, settings
        
        //title to use on the bar
        var title: String {
            switch self {
            case .history:
                return "History"
            case .routines:
                return "Routines"
            case .stats:
                return "Stats"
            case .settings:
                return "Settings"
            }
        }
        
        //systemImage icon to use on the bar
        var icon: String {
            switch self {
            case .history:
                return "list.bullet"
            case .routines:
                return "list.bullet.rectangle"
            case .stats:
                return "chart.bar"
            case .settings:
                return "gear"
                
            }
        }
    }
    
    
    //Navigaton paths
    @State private var historyPath: NavigationPath = .init()
    @State private var routinesPath: NavigationPath = .init()
    @State private var statsPath: NavigationPath = .init()
    @State private var settingsPath: NavigationPath = .init()
    
    //captures the theme color for storage in the environment
    @Query(filter: #Predicate<UserTheme> { theme in
        theme.isSelected == true
    }) var selectedTheme: [UserTheme]
    
    var selectedThemeString: String {
        if selectedTheme.isEmpty {
            return "#FF5733"
        } else {
            return selectedTheme.first!.lightModeHex
        }
        
    }
    
    var body: some View {
        ZStack(alignment:.bottom) {
            
            TabView(selection: $selectedTab) {
                //History
                NavigationStack (path: $historyPath){
                    WorkoutHistoryView(selectedTab: $selectedTab)
                        .globalKeyboardDoneButton()
                }
                .tag(Tab.history)
                .tint(Color(hexString: selectedThemeString))
                
                //Routines
                NavigationStack(path: $routinesPath){
                    RoutinesView(selectedTab: $selectedTab)
                        .globalKeyboardDoneButton()
                }
                .tag(Tab.routines)
                .tint(Color(hexString: selectedThemeString))
                
                //Stats
                NavigationStack(path: $statsPath){
                    StatsHomeView()
                        .globalKeyboardDoneButton()
                }
                .tag(Tab.stats)
                .tint(Color(hexString: selectedThemeString))
                
                //Settings
                NavigationStack(path: $settingsPath){
                    SettingsView()
                        .globalKeyboardDoneButton()
                }
                .tag(Tab.settings)
                .tint(Color(hexString: selectedThemeString))
                
            }
            
            
            //the tab bar on the bottom
            ZStack {
                Rectangle()
                    .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.0), // lower opacity at the top
                                    Color.white.opacity(0.8)  // higher opacity at the bottom
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    .frame(height:120)
                    
                bottomBar()
                    .frame(height: 60)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.5), radius: 5)
                    )
                    .padding(.horizontal, 17)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden)
        //storing the color in the env
        .environment(\.themeModel, selectedTheme.first ?? ThemeModelKey.defaultValue)
        .onAppear{
            //create default Categories and Exercise Templates
            initializeDefaultDataIfNeeded(context: modelContext)
            initializeDefaultThemes(in: modelContext)
            //create TEST exercise history
            //initializeWorkoutsIfNeeded(context: modelContext)
            
        }
    }
}

//MARK: Tab visuals
extension ContentView {
    func CustomTabItem(imageName:String, title: String, isActive:Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .foregroundStyle(isActive ? .black : .black.opacity(0.8))
            //if the tab is selected, change the color
            if isActive{
                Text(title)
                    .foregroundStyle(.black)
                    .lineLimit(1)                   // <-- never wrap
                    .truncationMode(.tail)          // <-- “…” at end
                    .layoutPriority(1)              // <-- ensure it gets priority to shrink
            }
            Spacer()
        }
        //if the tab is selected, make it more prominent
        .frame(maxWidth: isActive ? .infinity : 60)
        .frame(height: 50)
        .background(isActive ? Color(hexString: selectedThemeString).opacity(0.3) : .clear)
        .cornerRadius(30)
    }
}

//MARK: Tab Function
extension ContentView {
    func bottomBar() -> some View {
        HStack{
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    // Always reset the navigation stack for the selected tab
                    switch tab {
                    case .history:
                        historyPath = .init()
                    case .routines:
                        routinesPath = .init()
                    case .stats:
                        statsPath = .init()
                    case .settings:
                        settingsPath = .init()
                    }
                    
                    // Update the selected tab
                    selectedTab = tab
                } label: {
                    CustomTabItem(imageName: tab.icon, title: tab.title, isActive: (selectedTab == tab))
                }
            }
        }
        .padding(6)
    }
}

#Preview {
    ContentView()
}

