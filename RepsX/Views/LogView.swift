//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData

struct LogView: View {
    //Fetch workouts
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            List{
                ForEach(workouts) {workout in
                    logViewRow(for: workout)
                    
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .contentMargins(.horizontal,0)
            .navigationTitle("Log")
        }
    }
}

//Rows in the view
extension LogView {
    
    private func dateBlock(for workout: Workout) -> some View {
        VStack(alignment: .center) {
            let dayOfWeek = workout.startTime.formatted(.dateTime.weekday(.abbreviated))
            Text(dayOfWeek)
                .font(.headline)
            let day = workout.startTime.formatted(.dateTime.day())
            Text(day)
                .font(.subheadline)
                .bold()
        }
        .frame(width: 40, height: 50)
        .padding(1)
        .background(Color.white)
        .cornerRadius(6)
    }
    
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
    
    private func logViewRow(for workout: Workout) -> some View {
        HStack(alignment: .top) {
            // Date block (day-of-week and day)
            dateBlock(for: workout)
            
            // Workout details (name, duration, and exercise summary)
            workoutDetails(for: workout)
        }
        .padding(.vertical)
        .padding(.leading, 10)
        .padding(.trailing, 20)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    LogView()
        .modelContainer(SampleData.shared.modelContainer)
}
