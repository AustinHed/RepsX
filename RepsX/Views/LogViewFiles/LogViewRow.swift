//
//  LogViewRow.swift
//  RepsX
//
//  Created by Austin Hed on 2/25/25.
//

import SwiftUI
import UIKit

struct LogViewRow: View {
    
    var workout: Workout
    
    var body: some View {
        HStack(alignment: .top) {
            // Date block (day-of-week and day)
            dateBlock(for: workout)
                .padding(.leading)
            
            // Workout details (name, duration, and exercise summary)
            workoutDetails(for: workout)
        }
        .padding(.vertical)
        .padding(.leading, 10)
        .padding(.trailing, 20)
        .background(Color.white)
        .cornerRadius(12)
        //ratings overlay color
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12)
                .foregroundStyle(
                    
                    Color(UIColor(hex: workout.color ?? "#808080") ?? .clear)
                    
                )
                .frame(width:12),
            alignment: .leading
        )
        
    }
}

//MARK: Date
extension LogViewRow {
    private func dateBlock(for workout: Workout) -> some View {
        VStack(alignment: .center) {
            let dayOfWeek = workout.startTime.formatted(.dateTime.weekday(.abbreviated))
            Text(dayOfWeek)
                .bold()
                .font(.subheadline)
                .foregroundStyle(.secondary)
            let day = workout.startTime.formatted(.dateTime.day())
            Text(day)
                .font(.headline)
                .bold()
        }
        .frame(width: 40, height: 50)
        .padding(2)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

//MARK: Workout Details (headline, reps, set)
extension LogViewRow{
    private func workoutDetails(for workout: Workout) -> some View {
        VStack(alignment: .leading) {
            //headline and date
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                if let endTime = workout.endTime {
                    let duration = workout.workoutLength
                    Text("\(Int(duration/60)) min")
                        .font(.subheadline)
                } else {
                    Text("-")
                        .font(.subheadline)
                }
            }
            //reps and sets
            ForEach(workout.exercises, id: \.id) { exercise in
                HStack {
                    Text("\(exercise.sets.count) x")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(exercise.name)
                        .font(.subheadline)
                }
            }
        }
        
    }
}



// Hex initializer for Color
extension Color {
    init(hex: String) {
        // Remove any non-alphanumeric characters (like '#' or spaces)
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = (int >> 16) & 0xFF
        let g = (int >> 8) & 0xFF
        let b = int & 0xFF
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}

#Preview {
    let testWorkout:Workout = Workout(id: UUID(), name: "Test Workout", startTime: Date(), endTime: nil, rating: 4, exercises: [], color: "#EB5545")
    List{
        LogViewRow(workout: testWorkout)
            .listRowBackground(Color.clear)
            .listRowSeparator(Visibility.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    .contentMargins(.horizontal,0)
    .navigationTitle("Log")
    .modelContainer(SampleData.shared.modelContainer)
}
