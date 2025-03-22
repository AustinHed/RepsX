import SwiftUI

struct WorkoutHistoryCalendarView: View {
    let workouts: [Workout] // Array of logged workouts.
    @State private var isExpanded = false
    @State private var currentDate = Date()
    
    // Compute the dates for the current week (Sunday to Saturday) based on currentDate.
    private var weekDates: [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    // Computed property to show a nicely formatted week range (ex: "Mar 9 - 15").
    private var weekRangeText: String {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start,
              let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)
        else {
            return ""
        }
        let startDay = calendar.component(.day, from: startOfWeek)
        let endDay = calendar.component(.day, from: endOfWeek)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // e.g., "Mar"
        let startMonth = dateFormatter.string(from: startOfWeek)
        let endMonth = dateFormatter.string(from: endOfWeek)
        
        if calendar.component(.month, from: startOfWeek) == calendar.component(.month, from: endOfWeek) {
            return "\(startMonth) \(startDay) - \(endDay)"
        } else {
            return "\(startMonth) \(startDay) - \(endMonth) \(endDay)"
        }
    }
    
    // Compute the dates (and nil placeholders) for the current month grid.
    private var monthDates: [Date?] {
        var dates: [Date?] = []
        let calendar = Calendar.current
        // Get the first day of the month.
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }
        
        // Determine the weekday index (1 = Sunday, 2 = Monday, etc.) for the first day.
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        // Add nil for days before the first day of the month.
        for _ in 1..<firstWeekday {
            dates.append(nil)
        }
        // Add each day of the month.
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: firstOfMonth) {
                dates.append(date)
            }
        }
        // Optionally add trailing nil values so that the total count is a multiple of 7.
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        return dates
    }
    
    // Helper function to determine if a workout is logged on a specific date.
    private func hasWorkout(on date: Date) -> Bool {
        let calendar = Calendar.current
        return workouts.contains { (workout: Workout) -> Bool in
            calendar.isDate(workout.startTime, inSameDayAs: date)
        }
    }
    
    // Common header text: week range when contracted, or month/year when expanded.
    private var headerText: String {
        if isExpanded {
            return currentDate.formatted(.dateTime.month(.wide).year())
        } else {
            return weekRangeText
        }
    }
    
    //theme color
    @Environment(\.themeColor) var themeColor
    
    var body: some View {
        VStack(spacing: 10) {
            // Common header on the same horizontal plane.
            HStack {
                // Left navigation button.
                Spacer()
                Button(action: {
                    withAnimation {
                        if isExpanded {
                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
                                currentDate = newDate
                            }
                        } else {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate) {
                                currentDate = newDate
                            }
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(themeColor)
                }
                (Spacer(minLength: 40))
                
                // Right navigation button.
                Button(action: {
                    withAnimation {
                        if isExpanded {
                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
                                currentDate = newDate
                            }
                        } else {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate) {
                                currentDate = newDate
                            }
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(themeColor)
                }
                Spacer()
                
                // Header text.
                Text(headerText)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                Spacer()
                Spacer()

                // Expand/contract toggle button with extra left padding.
                Button(action: {
                    withAnimation (.spring) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .padding(.leading, 16)
                        .foregroundStyle(themeColor)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Calendar grid.
            if isExpanded {
                // Expanded view: Month grid.
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    // Weekday header with unique IDs.
                    ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    // Calendar cells.
                    ForEach(0..<monthDates.count, id: \.self) { index in
                        if let date = monthDates[index] {
                            let calendar = Calendar.current
                            let isFuture = calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
                            let backgroundColor: Color = {
                                if hasWorkout(on: date) {
                                    return themeColor.opacity(0.3)
                                } else if calendar.isDate(date, inSameDayAs: Date()) {
                                    return themeColor.opacity(0.1)
                                } else {
                                    return Color.clear
                                }
                            }()
                            
                            Text("\(calendar.component(.day, from: date))")
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                
                                .background(backgroundColor)
                                .cornerRadius(30) //was 8
                                .foregroundColor(isFuture ? .gray : .primary)
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding()
            } else {
                // Contracted view: Week view.
                HStack {
                    ForEach(weekDates, id: \.self) { date in
                        let calendar = Calendar.current
                        let isFuture = calendar.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
                        let backgroundColor: Color = {
                            if hasWorkout(on: date) {
                                return themeColor.opacity(0.3)
                            } else if calendar.isDate(date, inSameDayAs: Date()) {
                                return themeColor.opacity(0.1)
                            } else {
                                return Color.clear
                            }
                        }()
                        
                        VStack {
                            Text(date, format: .dateTime.weekday(.narrow))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                            Text("\(calendar.component(.day, from: date))")
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                               
                                .background(backgroundColor)
                                .cornerRadius(30) //was 8
                                .foregroundColor(isFuture ? .gray : .primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
        //.padding()
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutHistoryCalendarView(workouts: Workout.sampleData)
    }
}
