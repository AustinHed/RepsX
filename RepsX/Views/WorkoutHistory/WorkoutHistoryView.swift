//
//  LogView.swift
//  RepsX
//
//  Created by Austin Hed on 2/21/25.
//

import SwiftUI
import SwiftData
import SwipeActions
import Charts


struct WorkoutHistoryView: View {
    
    //Queries
    @Query(sort: \Workout.startTime, order: .reverse) var workouts: [Workout]
    @Query(filter: #Predicate{(routine:Routine) in
        return routine.favorite}, sort: \Routine.name) var favoriteRoutines: [Routine]
    @Query var exercisesList: [Exercise]
    
    //for the 30-day recap
    @State var lookback: RecapOptions = .Thirty
    private var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let thresholdDate = calendar.date(byAdding: .day, value: -lookback.rawValue, to: Date())!
        return workouts.filter{ $0.startTime > thresholdDate }
    }
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    
    //toggle to edit workouts, existing or new
    @State private var editNewWorkout: Bool = false
    @State private var editExistingWorkout: Bool = false
    
    //workout to edit, new or existing
    @State private var selectedWorkout: Workout?
    
    //deleting workout confirmation
    @State private var workoutToDelete: Workout?
    
    //View Model
    private var workoutViewModel: WorkoutViewModel {
        WorkoutViewModel(modelContext: modelContext)
    }
    
    //Tab
    @Binding var selectedTab: ContentView.Tab
    @State var coordinator = WorkoutCoordinator.shared
    
    //MARK: Body
    var body: some View {
        NavigationStack {
            ZStack{
                CustomBackground(themeColor: themeColor)
                ScrollView{ //was 12
                    LazyVStack(alignment: .leading, spacing: 12) {
                        
                        // Calendar at the top
                        calendarSection
                            
                        if workouts.isEmpty {
                            noWorkouts
                            
                        } else {
                            //30 day recap
                            recapSection
                            
                            //workouts
                            Text("Workouts")
                                .padding(.horizontal)
                                .font(.headline)
                                .bold()
                            ForEach(workouts) { workout in
                                //logViewRow
                                SwipeView{
                                    WorkoutHistoryRow(workout: workout)
                                        .onTapGesture {
                                            selectedWorkout = workout
                                        }
                                }
                                //swipe actions
                                trailingActions: { _ in
                                    SwipeAction(
                                        systemImage: "trash",
                                        backgroundColor: .red
                                    ){
                                        workoutToDelete = workout
                                    }
                                    .foregroundStyle(.white)

                                }
                                .swipeMinimumDistance(25)
                                .swipeActionCornerRadius(16)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: workouts)
                .contentMargins(.horizontal,0)
                .navigationTitle("History")
            }
            //MARK: Toolbar
            //add workout button
            .toolbar {
                menuToolbarItem
            }
            
            //MARK: Full Screen Covers
            //show edit workout views
            .fullScreenCover(isPresented: $editNewWorkout) { newWorkoutEditor }
            .fullScreenCover(item: $selectedWorkout) { workout in
                existingWorkoutEditor(for: workout)
                    .environment(\.modelContext, modelContext)
            }
            .fullScreenCover(isPresented: $coordinator.showEditWorkout) { coordinatorWorkoutEditor }
            //MARK: On Appear
            .safeAreaInset(edge: .bottom) {
                // Add extra space (e.g., 100 points)
                Color.clear.frame(height: 70)
            }
            
        }
        //MARK: Alert
        //delete workout confirmation
        .alert("Delete Workout?", isPresented: Binding<Bool>(
            get: { workoutToDelete != nil },
            set: { newValue in
                if !newValue { workoutToDelete = nil }
            }
        ), presenting: workoutToDelete) { workout in
            Button("Delete", role: .destructive) {
                withAnimation {
                    workoutToDelete = nil
                    workoutViewModel.deleteWorkout(workout)
                }
            }
            Button("Cancel", role: .cancel) {
                workoutToDelete = nil
            }
        } message: { workout in
            Text("Are you sure you want to delete this workout?")
        }
        
    }
}

//MARK: Calendar Section
extension WorkoutHistoryView {
    private var calendarSection: some View {
        VStack (alignment:.leading){
            Text("Calendar")
                .padding(.horizontal)
                .font(.headline)
                .bold()
            
            WorkoutHistoryCalendarView(workouts: workouts)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
        }
        
    }
}

//MARK: X-Day Recap
extension WorkoutHistoryView {
    //color function
    private func blendedColor(from: Color, to: Color, fraction: Double) -> Color {
        let uiFrom = UIColor(from)
        let uiTo = UIColor(to)
        
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        uiFrom.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        uiTo.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + CGFloat(fraction) * (toRed - fromRed)
        let green = fromGreen + CGFloat(fraction) * (toGreen - fromGreen)
        let blue = fromBlue + CGFloat(fraction) * (toBlue - fromBlue)
        let alpha = fromAlpha + CGFloat(fraction) * (toAlpha - fromAlpha)
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
    
    //Header
    private var workoutCount: Int {
        filteredWorkouts.count
    }
    private var totalWorkoutDuration: TimeInterval {
        let duration = filteredWorkouts.reduce(0) {$0 + $1.workoutLength}
        return duration / 60 //time intervals are in seconds
    }
    private var workoutNumber: some View {
            return Text("\(workoutCount)")
                .font(.largeTitle)
                .bold() +
            Text(" workouts")
                .font(.footnote)
                .foregroundStyle(.secondary)
    }
    private var workoutMinutes: some View {
        return Text("\(totalWorkoutDuration, specifier: "%.0f")")
            .font(.largeTitle)
            .bold() +
        Text(" minutes")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    private var workoutCountAndMinutes: some View {
        HStack {
            workoutNumber
            workoutMinutes
        }
    }
    
    //Categories and Chart
    private var overallCategoryDistribution: [(category: String, count: Int, percentage: Double)] {
        // Count frequency per category
        let exercises = filteredWorkouts.flatMap { $0.exercises }
        var frequency: [String: Int] = [:]
        for exercise in exercises {
            if exercise.category?.isHidden != true,
               let categoryName = exercise.category?.name,
               !categoryName.isEmpty {
                frequency[categoryName, default: 0] += 1
            }
        }
        // Total exercises
        let totalCount = frequency.values.reduce(0, +)
        // Build sorted list of (name, count, percentage)
        let rawList = frequency.map { (category: $0.key,
                                       count: $0.value,
                                       percentage: totalCount > 0 ? (Double($0.value) / Double(totalCount) * 100) : 0)
        }
        .sorted { $0.count > $1.count }

        // If more than 6 categories, group the rest into "Other"
        if rawList.count > 6 {
            let topSix = rawList.prefix(6)
            let others = rawList.dropFirst(6)
            let otherCount = others.reduce(0) { $0 + $1.count }
            let otherPercentage = totalCount > 0 ? (Double(otherCount) / Double(totalCount) * 100) : 0
            var result = Array(topSix)
            result.append((category: "Other", count: otherCount, percentage: otherPercentage))
            return result
        } else {
            return rawList
        }
    }
    private var categoryTextList: some View {
        VStack(alignment:.leading) {
            let totalEntries = overallCategoryDistribution.count
            ForEach(Array(overallCategoryDistribution.enumerated()), id: \.element.category) { (index, entry) in
                let fraction = totalEntries > 1 ? Double(index) / Double(totalEntries - 1) : 0.0
                let opacity = 1.0 - fraction * 0.6
                let blended = blendedColor(from:themeColor, to: .gray, fraction: fraction)
                
                HStack{
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(blended)
                    Text("\(entry.category)")
                    Spacer()
                    Text("\(entry.percentage, specifier: "%.0f")%")
                }
                .foregroundStyle(.secondary)
                .font(.footnote)
            }
        }
        .padding(.horizontal)
        //.padding(.bottom)
    }
    private var pieChartView: some View {
        Chart {
            let totalEntries = overallCategoryDistribution.count
            ForEach(Array(overallCategoryDistribution.enumerated()), id: \.element.category) { (index, entry) in
                //determine the order, and the color based on the order
                let fraction = totalEntries > 1 ? Double(index) / Double(totalEntries - 1) : 0.0
                let opacity = 1.0 - fraction * 0.6
                let blended = blendedColor(from:themeColor, to: .gray, fraction: fraction)
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.6), // Use a ratio value to get a donut look
                    angularInset: 2           // Adds separation between slices
                )
                .cornerRadius(4)
                .foregroundStyle(blended.opacity(opacity))
            }
        }
        .frame(height: 125)
    }
    
    //Result
    private var recapSection: some View {
        VStack(alignment: .leading) {
            // Timeframe selector
            HStack {
                Text("\(lookback)-Day Recap")
                    .font(.headline)
                    .bold()
                    //.border(.orange)
                Spacer()
                EnumPicker<RecapOptions>(selection: $lookback) { option in
                    "\(option.rawValue)d"
                }
                //.border(.red)
            }
            .padding(.horizontal)
            //Content
            //if workouts, else without workouts
            if workoutCount > 0 {
                VStack(alignment: .leading) {
                    workoutCountAndMinutes
                        .padding(.horizontal)
                        .padding(.top,10)
                    
                    HStack (alignment:.center){
                        pieChartView
                            .padding(.leading)
                        categoryTextList
                            .padding(.trailing)
                            
                    }
                    .padding(.bottom,20)
                }
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
            } else {
                HStack{
                    Text("No Data")
                        .font(.largeTitle)
                        .bold() +
                    Text(" for the selected period")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
                
            }
            
        }
        
        
    }
    
}

//MARK: No Workouts State
extension WorkoutHistoryView {
    private var noWorkouts: some View {
        Button {
            let createdWorkout = workoutViewModel.addWorkout(date: Date())
            selectedWorkout = createdWorkout
            editNewWorkout = true
        } label: {
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.white)
                    .frame(height: 45)
                    .padding(.horizontal)
                
                Text("Start your first workout")
                    .foregroundStyle(themeColor)
            }
        }
    }
}
//MARK: Toolbar contents
extension WorkoutHistoryView {
    //add workout menu
    private var menuToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                //net new workout
                Section {
                    Button("New Workout") {
                        let createdWorkout = workoutViewModel.addWorkout(date: Date())
                        selectedWorkout = createdWorkout
                        editNewWorkout = true
                    }
                }
                
                //favorite workouts
                Section("Favorite Routines") {
                    ForEach(favoriteRoutines) { routine in
                        Button(routine.name) {
                            let createdWorkout = workoutViewModel.addWorkoutFromRoutine(routine, date: Date())
                            selectedWorkout = createdWorkout
                            editNewWorkout = true
                            print("added workout from Routine")
                        }
                    }
                }
                
                //cancel button
                Section {
                    Button(role: .destructive) {
                        //no action
                    } label: {
                        Text("Cancel")
                    }
                }
                
            } label: {
                Image(systemName: "plus.circle")
            }
            .foregroundStyle(themeColor)
        }
    }
}
//MARK: Fullscreen Covers
extension WorkoutHistoryView {
    //new workout editor
    //TODO: need to pass all workouts here
    private var newWorkoutEditor: some View {
        Group {
            if let workoutToEdit = selectedWorkout {
                NavigationStack {
                    EditWorkoutView(workout: workoutToEdit)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Finish") {
                                    workoutViewModel.updateWorkout(workoutToEdit, newEndTime: Date())
                                    if workoutToEdit.name.isEmpty {
                                        let dateName = String(workoutViewModel.toolbarDate(workoutToEdit.startTime))
                                        workoutViewModel.updateWorkout(workoutToEdit, newName:"Workout on \(dateName)")
                                    }
                                    editNewWorkout = false
                                    selectedWorkout = nil
                                }
                                .foregroundStyle(themeColor)
                            }
                        }
                }
                .environment(\.modelContext, modelContext)
            }
        }
    }
    
    //existing workout editor
    private func existingWorkoutEditor(for workout: Workout) -> some View {
        NavigationStack {
            EditWorkoutView(workout: workout)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            // Final updates before dismissing
                            if workout.name.isEmpty {
                                workoutViewModel.updateWorkout(workout, newName: "Unnamed Workout")
                            }
                            selectedWorkout = nil
                        }
                        .foregroundStyle(themeColor)
                    }
                }
        }
    }
    
    //workout coordinator
    private var coordinatorWorkoutEditor: some View {
        Group {
            if let workout = coordinator.currentWorkout {
                NavigationStack {
                    EditWorkoutView(workout: workout)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Finish") {
                                    workoutViewModel.updateWorkout(workout, newEndTime: Date())
                                    coordinator.showEditWorkout.toggle()
                                }
                                .foregroundStyle(themeColor)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    WorkoutHistoryView(selectedTab: .constant(.history))
}


