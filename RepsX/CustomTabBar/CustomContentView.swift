import SwiftUI
import SwiftData

struct MainTabbedView: View {
    
    @State private var selectedTab: TabOptions = .history
    
    @Environment(\.modelContext) private var modelContext
    
    //This hides the bar at the bottom of the screen
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    //enum of tabs
    enum TabOptions: CaseIterable {
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
    
    
    //captures the theme color for storage in the environment
    @Query(filter: #Predicate<UserTheme> { theme in
        theme.isSelected == true
    }) var selectedTheme: [UserTheme]
    
    var body: some View {
        ZStack(alignment:.bottom) {
            
            //the views to show - currently placeholders
            TabView(selection: $selectedTab) {
                WorkoutHistoryView(selectedTab: $selectedTab)
                    .tag(TabOptions.history)
                    .toolbar(.hidden)
                
                RoutinesView(selectedTab: $selectedTab)
                    .tag(TabOptions.routines)
                    .toolbar(.hidden)
                
                StatsHomeView(selectedTab: $selectedTab)
                    .tag(TabOptions.stats)
                
                SettingsView(selectedTab: $selectedTab)
                    .tag(TabOptions.settings)
                    .toolbar(.hidden)
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
        .environment(\.themeColor, Color(hexString: selectedTheme.first!.primaryHex))
    }
}

//MARK: tab item items
extension MainTabbedView {
    func CustomTabItem(imageName:String, title: String, isActive:Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .foregroundStyle(isActive ? .black : .black.opacity(0.8))
            //if the tab is selected, change the color
            if isActive{
                Text(title)
                    .foregroundStyle(.black)
            }
            Spacer()
        }
        //if the tab is selected, make it more prominent
        .frame(maxWidth: isActive ? .infinity : 60)
        .frame(height: 50)
        .background(isActive ? Color(hexString: selectedTheme.first!.primaryHex).opacity(0.3) : .clear)
        .cornerRadius(30)
    }
}

//MARK: the tab bar
extension MainTabbedView {
    func bottomBar() -> some View {
        HStack{
            ForEach((TabOptions.allCases), id: \.self){ item in
                Button{
                    selectedTab = item
                } label: {
                    CustomTabItem(imageName: item.icon, title: item.title, isActive: (selectedTab == item))
                }
            }
        }
        .padding(6)
    }
}

#Preview {
    MainTabbedView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self])
}
