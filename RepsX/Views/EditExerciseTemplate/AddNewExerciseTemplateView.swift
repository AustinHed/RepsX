import SwiftUI
import SwiftData

struct AddNewExerciseTemplateView: View {
    // Optionally provided default category
    var category: CategoryModel?
    
    @Query(
        filter: #Predicate<CategoryModel>{ category in
            category.isHidden == false
        },
        sort: \CategoryModel.name
    ) var categories: [CategoryModel]
    
    var standardCategories: [CategoryModel] {
        categories.filter {$0.standard == true}
    }
    var customCategories: [CategoryModel] {
        categories.filter {$0.standard == false}
    }
    
    //environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // View Models (if needed)
    private var categoryViewModel: CategoryViewModel {
        CategoryViewModel(modelContext: modelContext)
    }
    private var exerciseTemplateViewModel: ExerciseTemplateViewModel {
        ExerciseTemplateViewModel(modelContext: modelContext)
    }
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
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
                    .foregroundStyle(primaryColor)
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
                    .foregroundStyle((templateName.isEmpty || selectedCategory == nil) ? Color.gray : primaryColor)
                }
            }
            //MARK: On Appear
            .onAppear {
                // If no category has been selected yet, default to the provided category.
                if selectedCategory == nil {
                    selectedCategory = category
                }
                print("\(primaryColor)")
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
                CustomBackground(primaryColor: primaryColor)
            )
            .tint(primaryColor)
        }

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
                Section(header:
                            HStack{
                    Text("Standard Categories")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.black)
                        .textCase(nil)
                    Spacer()
                }
                    .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                ){
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
                
                if !customCategories.isEmpty {
                    Section(header:
                                HStack{
                        Text("Custom Categories")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.black)
                            .textCase(nil)
                        Spacer()
                    }
                        .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                    ){
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
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
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

        case .endurance:
            return Text("Distance, Time")
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
            //MARK: Background
            .scrollContentBackground(.hidden)
            .background(
                CustomBackground(primaryColor: primaryColor)
            )
        }
    }
}

#Preview {
    AddNewExerciseTemplateView()
}


