import SwiftUI
import SwiftData

struct AddNewExerciseTemplateView: View {
    // Optionally provided default category
    var category: CategoryModel?
    
    //Fetch standard categories
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == true &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var standardCategories: [CategoryModel]
    
    //Fetch custom categories
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.standard == false &&
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var customCategories: [CategoryModel]
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) private var dismiss
    
    // View Models (if needed)
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
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
                //exercise name
                exerciseNameSection
                //category select
                categorySelectionSection
                //modality select
                modalitySelectionSection
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
                    .foregroundStyle(themeColor)
                }
                
                //done button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if selectedCategory != nil {
                            exerciseTemplateViewModel.addExerciseTemplate(
                                name: templateName,
                                category: selectedCategory!,
                                modality: selectedModality
                            )
                            dismiss()
                        }
                    }
                    .disabled(templateName.isEmpty || selectedCategory == nil)
                    .foregroundStyle((templateName.isEmpty || selectedCategory == nil) ? Color.gray : themeColor)
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
                categoryPickerSheet
            }
            //modality picker
            .sheet(isPresented: $isModalityPickerPresented) {
                modalityPickerSheet()
            }
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(themeColor: themeColor)
            )
        }
        .tint(themeColor)
    }
}

//MARK: Name
extension AddNewExerciseTemplateView {
    private var exerciseNameSection: some View {
        Section {
            HStack {
                Text("Name")
                Spacer()
                TextField("Unnamed Exercise", text: $templateName)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

//MARK: Category
extension AddNewExerciseTemplateView {
    //select category button
    private var categorySelectionSection: some View {
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
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    //category picker
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                
                Section("Default Categories"){
                    ForEach(standardCategories) { cat in
                        Button {
                            selectedCategory = cat
                            isCategoryPickerPresented = false
                        } label: {
                            Text(cat.name)
                                .foregroundStyle(.black)
                        }
                    }
                }
                
                Section("Custom Categories"){
                    ForEach(customCategories) { cat in
                        Button {
                            selectedCategory = cat
                            isCategoryPickerPresented = false
                        } label: {
                            Text(cat.name)
                                .foregroundStyle(.black)
                        }
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
}

//MARK: Modality
extension AddNewExerciseTemplateView {
    
    private var modalitySelectionSection: some View {
        Section {
            Button {
                isModalityPickerPresented.toggle()
            } label: {
                HStack {
                    Text("Modality")
                        .foregroundStyle(.black)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(selectedModality.rawValue.capitalized)
                            .foregroundColor(.primary)
                        modalityDetail
                    }
                }
            }
        } footer: {
            Text("How an exercise is performed, and how measures are used to track performance (Weight, Reps, Time)")
        }
    }
    
    private var modalityDetail: some View {
        switch selectedModality {
        case .repetition:
            return Text("Weight, Reps")
                .font(.caption)
                .foregroundColor(.secondary)
        case .tension:
            return Text("Weight, Time")
                .font(.caption)
                .foregroundColor(.secondary)
        case .endurance:
            return Text("Distance, Time")
                .font(.caption)
                .foregroundColor(.secondary)
        case .other:
            return Text("Other")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    func modalityPickerSheet() -> some View {
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
    }
}

#Preview {
    AddNewExerciseTemplateView()
}


