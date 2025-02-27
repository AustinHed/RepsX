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
    // The selected category; default to the passed-in category if available.
    @State var selectedCategory: CategoryModel? = nil
    // Controls the presentation of the category picker.
    @State var isCategoryPickerPresented: Bool = false
    
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
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            // Add custom toolbar items
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
                            exerciseTemplateViewModel.addPredefinedExercise(
                                name: templateName,
                                category: selectedCategory!
                            )
                            dismiss()
                        }
                    }
                    .disabled(templateName.isEmpty || selectedCategory == nil)
                }
            }
            .onAppear {
                // If no category has been selected yet, default to the provided category.
                if selectedCategory == nil {
                    selectedCategory = category
                }
            }
            // The sheet presents a list of all categories.
            .sheet(isPresented: $isCategoryPickerPresented) {
                NavigationStack {
                    List {
                        ForEach(categories) { cat in
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
        }
    }
}

#Preview {
    CreateNewExerciseTemplateView()
}


