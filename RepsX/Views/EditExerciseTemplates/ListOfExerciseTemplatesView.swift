import SwiftUI
import SwiftData

struct ListOfExerciseTemplatesView<Destination: View>: View {
    
    // Fetch ExerciseTemplates
    @Query(filter: #Predicate<ExerciseTemplate>{
        exerciseTemplate in exerciseTemplate.hidden == false
    }, sort: \ExerciseTemplate.name)
    var exercises: [ExerciseTemplate]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // View Model
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    // Theme View Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    // The category to filter on. nil means no filter.
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
        let cats = exercises.compactMap { $0.category }
        var uniqueCategories: [CategoryModel] = []
        
        for cat in cats {
            // Check uniqueness based on the category name. If you have an id, use that instead.
            if !uniqueCategories.contains(where: { $0.id == cat.id }) {
                uniqueCategories.append(cat)
            }
        }
        
        return uniqueCategories.sorted { $0.name < $1.name }
    }
    
    // Computed property that filters exercises based on the selected category.
    var filteredExercises: [ExerciseTemplate] {
        if let selected = selectedCategory {
            return exercises.filter { $0.category == selected }
        } else {
            return exercises
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                // List the filtered exercise templates.
                ForEach(filteredExercises) { exercise in
                    NavigationLink(exercise.name) {
                        destinationBuilder(exercise)
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
                    .foregroundStyle(userThemeViewModel.primaryColor)
                }
            }
            // MARK: Sheets
            .sheet(isPresented: $isAddingNewExercise) {
                AddNewExerciseTemplateView()
            }
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
