//
//  RoutineItem.swift
//  RepsX
//
//  Created by Austin Hed on 3/24/25.
//

import SwiftUI
import SwiftData

struct RoutineItem: View {
    
    let routine: Routine
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    //the maximum number of items to show
    let maxDisplayCount = 3
 
    var body: some View {
        
        VStack(alignment:.leading){
            HStack {
                Text(routine.name)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                if routine.favorite{
                    Image(systemName:"star.circle.fill")
                        .foregroundStyle(.yellow)
                }
                
            }
            
            //if there are no exercises
            if routine.exercises.isEmpty {
                Text("No exercises in this routine")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            } else {
                ForEach(routine.exercises.prefix(maxDisplayCount), id: \.self) { exercise in
                    Text(exercise.exerciseName)
                        .foregroundStyle(Color.primary)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        
                }
            }

            // If there are more than X exercises
            if routine.exercises.count > maxDisplayCount {
                let extraCount = routine.exercises.count - maxDisplayCount
                Text("& \(extraCount) more...")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
            
            
        }
        .padding(15)
        .frame(width: .infinity, height: 140)
        .background(Color("lightAndDarkBackgrounds"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    
    let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
    let routine:Routine = Routine(name:"Chest Day", favorite: true)
    NavigationStack{
        VStack{
            Spacer()
            RoutineItem(routine: routine)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            CustomBackground(primaryColor: Color.blue)
                .edgesIgnoringSafeArea(.all)
        )
        
        
    }
    .background(.red)
}
