import SwiftUI
import SwiftData

struct ListOfExerciseTemplatesView<Destination: View>: View {
    
    // Fetch standard ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{ exerciseTemplate in
        exerciseTemplate.standard == true
    }, sort: \ExerciseTemplate.name)
    var standardExercises: [ExerciseTemplate]
    
    //fetch custom ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{ exerciseTemplate in
        exerciseTemplate.standard == false &&
        exerciseTemplate.hidden == false
    }, sort: \ExerciseTemplate.name) var customExercises: [ExerciseTemplate]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColor) var themeColor
    
    // View Model
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //Filter options
    @State var selectedCategory: CategoryModel? = nil
    
    // Add new exercise
    @State private var isAddingNewExercise: Bool = false
    
    // Navigation title (depends on how this view is accessed)
    let navigationTitle: String
    
    // Optionally passing through a list of workouts
    let allWorkouts: [Workout]?
    
    // This closure builds the destination view for a given exercise.
    let destinationBuilder: (ExerciseTemplate) -> Destination
    
    init(navigationTitle: String,
         allWorkouts: [Workout]? = nil,
         @ViewBuilder destinationBuilder: @escaping (ExerciseTemplate) -> Destination) {
        self.navigationTitle = navigationTitle
        self.allWorkouts = allWorkouts
        self.destinationBuilder = destinationBuilder
    }
    
    // Computed property that returns all available categories from the fetched exercises.
    var categories: [CategoryModel] {
        let cats = standardExercises.compactMap { $0.category }
        let cats2 = customExercises.compactMap { $0.category }
        var uniqueCategories: [CategoryModel] = []

        for cat in cats {
            // Check uniqueness based on the category name. If you have an id, use that instead.
            if !uniqueCategories.contains(where: { $0.id == cat.id }) {
                uniqueCategories.append(cat)
            }
        }
        
        for cat in cats2 {
            if !uniqueCategories.contains(where: { $0.id == cat.id }) {
                uniqueCategories.append(cat)
            }
        }
        
        return uniqueCategories.sorted { $0.name < $1.name }
    }
    
    // Computed property that filters exercises based on the selected category.
    var filteredStandardExercises: [ExerciseTemplate] {
        if let selected = selectedCategory {
            return standardExercises.filter { $0.category == selected }
        } else {
            return standardExercises
        }
    }
    
    //all custom exercises for a selected category
    var filteredCustomExercises: [ExerciseTemplate] {
        if let selected = selectedCategory {
            return customExercises.filter { $0.category == selected }
        } else {
            return customExercises
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                Section("Standard Exercises") {
                    // List the filtered exercise templates.
                    ForEach(filteredStandardExercises) { exercise in
                        NavigationLink(exercise.name) {
                            destinationBuilder(exercise)
                        }
                    }
                }
                
                if !filteredCustomExercises.isEmpty {
                    Section("Custom Exercises") {
                        ForEach(filteredCustomExercises) { exercise in
                            NavigationLink(exercise.name) {
                                destinationBuilder(exercise)
                            }
                        }
                    }
                }
                
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Toolbar
            .toolbar {
                
                //filter exercises
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Filter by Category") {
                            Button {
                                selectedCategory = nil
                            } label: {
                                categoryFilterLabel(text: "All", category: nil)
                            }
                            
                            ForEach(categories, id: \.self) {category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    categoryFilterLabel(text: category.name, category: category)
                                }
                            }
                        }
                        
                        Section("Filter by Modality") {
                            
                        }
                    } label: {
                        if selectedCategory != nil {
                            Image(systemName:"line.3.horizontal.circle.fill")
                        } else {
                            Image(systemName:"line.3.horizontal.decrease.circle")
                        }
                        
                    }
                }
                
                //add new exercise
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingNewExercise.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .foregroundStyle(themeColor)
                }
            }
            // MARK: Sheets
            .sheet(isPresented: $isAddingNewExercise) {
                AddNewExerciseTemplateView()
            }
            .safeAreaInset(edge: .bottom) {
                // Add extra space (e.g., 100 points)
                Color.clear.frame(height: 100)
            }
            //MARK: Background
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
}

extension ListOfExerciseTemplatesView {
    @ViewBuilder
    private func categoryFilterLabel(text:String, category: CategoryModel?) -> some View {
        if category == selectedCategory {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "checkmark")
            }
        } else {
            Text(text)
        }
    }
}
