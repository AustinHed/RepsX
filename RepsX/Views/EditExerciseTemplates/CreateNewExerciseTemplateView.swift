import SwiftUI
import SwiftData

struct CreateNewExerciseTemplateView: View {
    // Optionally provided default category
    var category: CategoryModel?
    
    // Fetch all CategoryModel objects.
    @Query(sort: \CategoryModel.name, order: .reverse) var categories: [CategoryModel]
    @Environment(\.modelContext) private var modelContext
    
    // View Models (if needed)
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //dismiss
    @Environment(\.dismiss) private var dismiss
    
    // State for the template
    @State var templateName: String = ""
    
    //Select Category
    @State var selectedCategory: CategoryModel? = nil
    @State var isCategoryPickerPresented: Bool = false
    //Select Modality
    @State var selectedModality: ExerciseModality = .repetition
    @State var isModalityPickerPresented: Bool = false
    
    var body: some View {
        NavigationStack{
            
            List {
                // Row 1: Exercise Name
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Unnamed Exercise", text: $templateName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Row 2: Category Selection
                Section {
                    Button {
                        isCategoryPickerPresented = true
                    } label: {
                        HStack {
                            Text("Category")
                                .foregroundStyle(.black)
                            Spacer()
                            if let selected = selectedCategory {
                                Text(selected.name)
                                    .foregroundColor(.primary)
                            } else {
                                Text("Select a category")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                //Row 3: Exercise Modality Selection
                Section {
                    Button {
                        isModalityPickerPresented.toggle()
                    } label: {
                        HStack {
                            Text("Modality")
                                .foregroundStyle(.black)
                            Spacer()
                            VStack (alignment:.leading){
                                Text(selectedModality.rawValue.capitalized)
                                    .foregroundColor(.primary)
                                switch selectedModality {
                                case .repetition:
                                    Text("Weight, Reps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                case .tension:
                                    Text("Weight, Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                case .endurance:
                                    Text("Distance, Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                default:
                                    Text("Other")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                        }
                    }
                    
                }
                footer: {
                    Text("How an exercise is performed, and how measures are used to track performance (Weight, Reps, Time)")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            //MARK: Toolbar
            .toolbar {
                //close button
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                //done button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if selectedCategory != nil {
                            exerciseTemplateViewModel.addExerciseTemplate(
                                name: templateName,
                                category: selectedCategory!,
                                modality: .repetition
                            )
                            dismiss()
                        }
                    }
                    .disabled(templateName.isEmpty || selectedCategory == nil)
                }
            }
            //MARK: On Appear
            .onAppear {
                // If no category has been selected yet, default to the provided category.
                if selectedCategory == nil {
                    selectedCategory = category
                }
            }
            //MARK: Sheets
            //category picker
            .sheet(isPresented: $isCategoryPickerPresented) {
                NavigationStack {
                    List {
                        ForEach(categories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }) { cat in
                            Button {
                                selectedCategory = cat
                                isCategoryPickerPresented = false
                            } label: {
                                Text(cat.name)
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    .navigationTitle("Select Category")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                isCategoryPickerPresented = false
                            }
                        }
                    }
                }
                .environment(\.modelContext, modelContext)
            }
            //modality picker
            .sheet(isPresented: $isModalityPickerPresented) {
                NavigationStack {
                    List {
                        //reps
                        Section {
                            Button("Repetition") {
                                selectedModality = .repetition
                                isModalityPickerPresented = false
                            }
                            .foregroundStyle(.black)
                        } footer: {
                            Text("For exercises measured in Weight and Reps \nex. Bench Press, Squats, Deadlift, etc.")
                        }

                        //tension
                        Section {
                            Button("Tension") {
                                selectedModality = .tension
                                isModalityPickerPresented = false
                            }
                            .foregroundStyle(.black)
                        } footer: {
                            Text("For exercises measured in Weight and Time \nex. Wallsits, Weighted Plank, etc.")
                        }
                        
                        //endurance
                        Section {
                            Button("Endurance") {
                                selectedModality = .endurance
                                isModalityPickerPresented = false
                            }
                            .foregroundStyle(.black)
                        } footer: {
                            Text("For exercises measured in Distance and Time \nex. Running, Rowing, Cycling, etc.")
                        }
                        
                        //other
                        Section {
                            Button("Other") {
                                selectedModality = .other
                                isModalityPickerPresented = false
                            }
                            .foregroundStyle(.black)
                        } footer: {
                            Text("For exercises not measured as the above \nex. Yoga, Pilates, etc. ")
                        }
                    }
                    .navigationTitle("Select Modality")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                isModalityPickerPresented = false
                            }
                        }
                    }
                }
                .environment(\.modelContext, modelContext)
            }
        }
    }
}

#Preview {
    CreateNewExerciseTemplateView()
}


