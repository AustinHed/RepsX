//
//  SelectAppIconView.swift
//  RepsX
//
//  Created by Austin Hed on 4/5/25.
//

import SwiftUI

//App Icon Struct
struct AppIcon: Identifiable {
    //identifier for the icon
    let id: UUID = UUID()
    //The actual icon
    let iconName: String
    //The image of the icon
    let imageName: String
}

struct SelectAppIconView: View {
    
    //Current app icon
    @AppStorage("activeAppIcon") var activeAppIcon: String = "iconDumbellsAnime"
    @Environment(\.themeColor) var themeColor
    
    //initialize the icons
    let appIconOptions: [AppIcon] = [
        AppIcon(iconName: "iconDumbellsAmerica", imageName: "dumbellsAmerica"),
        AppIcon(iconName: "iconDumbellsBlack", imageName: "dumbellsBlack"),
        AppIcon(iconName: "iconDumbellsRainbow", imageName: "dumbellsRainbow")
    ]
    
    var body: some View {
        ScrollView{
            HStack (alignment: .center){
                Image("dumbellsAnime")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke("iconDumbellsAnime" == activeAppIcon ? .white : .clear, lineWidth: 3)
                        )
                    .padding(15)
                    .onTapGesture{
                        UIApplication.shared.setAlternateIconName(nil)
                        activeAppIcon = "iconDumbellsAnime"
                    }
                ForEach(appIconOptions){ option in
                    HStack{
                        Image(option.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(option.iconName == activeAppIcon ? .white : .clear, lineWidth: 3)
                                )
                            .padding(15)
                            .onTapGesture{
                                changeAppIcon(to: option.iconName)
                            }
                        Spacer()
                    }
                    
                }
            }
            
        }
        .frame(width: 400)
        .background(CustomBackground(themeColor: themeColor))
        .navigationTitle("App Icons")
    }
    
    private func changeAppIcon(to iconName: String){
        guard UIApplication.shared.supportsAlternateIcons else {
            print( "Alternate icons are not supported on this device." )
            return
        }
        
        let newIconName = iconName.isEmpty ? nil : iconName
        UIApplication.shared.setAlternateIconName(newIconName) {error in
            if let error = error {
                print("Error changing app icon: \(error.localizedDescription)")
            } else {
                activeAppIcon = newIconName ?? "Something Failed"
                print("Changed icon successfully!")
            }
        }
    }
}

#Preview {
    NavigationStack{
        SelectAppIconView()
    }
    
}
