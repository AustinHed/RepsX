//
//  RoutinesView.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI
import SwiftData
import Foundation

struct RoutinesView: View {
    
    //Fetch workouts
    //@Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack{
            List {
                Text("Hat")
                Text("Hat")
                Text("Hat")
                Text("Hat")
            }
            .navigationTitle("Routines")
            .toolbar {
                
                //Edit Button
                ToolbarItem(placement: .topBarLeading) {
                    Text("Edit")
                }
                
                //Plus button
                ToolbarItem(placement: .topBarTrailing) {
                    Text("plus")
                }
            }
        }
    }
}

#Preview {
    RoutinesView()
}
