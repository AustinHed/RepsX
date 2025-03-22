import SwiftUI

struct ExerciseHistoryView: View {
    
    // The list of all workouts, passed from the previous view
    let workouts: [Workout]
    // The exercise template for which we want to show history.
    let exerciseTemplate: ExerciseTemplate

    // A simple model representing an individual set performed for this exercise.
    struct SetHistory: Identifiable {
        let id = UUID()
        let workoutDate: Date
        let weight: Double
        let reps: Int
    }

    // Compute an array of SetHistory by flattening workouts.
    private var setHistory: [SetHistory] {
        // Loop through workouts, filter out exercises matching the provided template,
        // then flatten their sets into a list of SetHistory records.
        workouts.flatMap { workout in
            workout.exercises.filter { exercise in
                // Only include exercises that match the provided exercise template.
                exercise.templateId == exerciseTemplate.id
            }.flatMap { exercise in
                exercise.sets.map { set in
                    SetHistory(workoutDate: workout.startTime,
                               weight: set.weight,
                               reps: set.reps)
                }
            }
        }
        // Optionally sort by workout date (most recent first).
        .sorted { $0.workoutDate > $1.workoutDate }
    }
    
    @Environment(\.themeColor) var themeColor

    var body: some View {
        List(setHistory) { record in
                rowView(for: record)
            }
        .navigationTitle("History: \(exerciseTemplate.name)")
        .navigationBarTitleDisplayMode(.inline)
        //Background
        .scrollContentBackground(.hidden)
        .background(
            ZStack{
                themeColor.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                WavyBackground(startPoint: 50,
                               endPoint: 120,
                               point1x: 0.6,
                               point1y: 0.1,
                               point2x: 0.4,
                               point2y: 0.015,
                               color: themeColor.opacity(0.1)
                )
                    .edgesIgnoringSafeArea(.all)
                WavyBackground(startPoint: 120,
                               endPoint: 50,
                               point1x: 0.4,
                               point1y: 0.01,
                               point2x: 0.6,
                               point2y: 0.25,
                               color: themeColor.opacity(0.1)
                )
                    .edgesIgnoringSafeArea(.all)
            }
        )
    }
}

//MARK: Rows
extension ExerciseHistoryView {
    /// Returns a view for a given SetHistory record.
    private func rowView(for record: SetHistory) -> some View {
        HStack {
            
            // Date column.
            VStack(alignment: .leading) {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(record.workoutDate, format: Date.FormatStyle.dateTime
                        .month(.twoDigits)
                        .day(.twoDigits)
                        .year())
            }
            .frame(width: 120, alignment: .leading)
            Spacer()
            
            // Reps column.
            VStack(alignment: .leading) {
                Text("Reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(record.reps)")
            }
            .frame(width: 60, alignment: .leading)
            
            // Weight column.
            VStack(alignment: .leading) {
                Text("Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(record.weight, specifier: "%.1f")")
            }
            .frame(width: 80, alignment: .leading)
        }
        .padding(.horizontal, 5)
    }
}
