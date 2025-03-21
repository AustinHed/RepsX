import SwiftUI
import SwiftData

//enum of tabs
enum TabOptions: Int, CaseIterable {
    case history = 0
    case routines
    case stats
    case settings
    
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

struct MainTabbedView: View {
    
    @State var selectedTab = 0
    
    var body: some View {
        ZStack(alignment:.bottom) {
            
            //the views to show - currently placeholders
            TabView(selection: $selectedTab) {
                Text("History")
                    .tag(0)
                
                Text("Routines")
                    .tag(1)
                
                Text("Stats")
                    .tag(2)
                
                Text("Settings")
                    .tag(3)
            }
            
            //the tab bar on the bottom
            ZStack{
                bottomBar()
            }
            .frame(height: 70)
            .background(.purple.opacity(0.2))
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }
    }
}

//MARK: tab item items
extension MainTabbedView {
    func CustomTabItem(imageName:String, title: String, isActive:Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .foregroundStyle(isActive ? .black : .gray)
            //if the tab is selected, change the color
            if isActive{
                Text(title)
                    //.font(.system(size:14))
                    .foregroundStyle(isActive ? .black : .gray)
            }
            Spacer()
        }
        //if the tab is selected, make it more prominent
        .frame(width: isActive ? .infinity : 60, height: 60)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}

//MARK: the tab bar
extension MainTabbedView {
    func bottomBar() -> some View {
        HStack{
            ForEach((TabOptions.allCases), id: \.self){ item in
                Button{
                    selectedTab = item.rawValue
                } label: {
                    CustomTabItem(imageName: item.icon, title: item.title, isActive: (selectedTab == item.rawValue))
                }
            }
        }
        .padding(6)
    }
}

#Preview {
    MainTabbedView()
}
