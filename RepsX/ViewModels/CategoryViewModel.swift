//
//  CategoryViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class CategoryViewModel {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //add
    func addCategory(name: String)  {
        let newCategory = CategoryModel(id: UUID(), name: name)
        modelContext.insert(newCategory)
        save()
    }
    
    //delete
    
    //delete a workout from Memory
    func deleteCategory(_ category: CategoryModel) {
        //then, delete the workout
        modelContext.delete(category)
        //then, save
        save()
    }
    
    //update name
    //TODO: update category name
    
    //fetch
    
    func fetchCategories() -> [CategoryModel] {
        let descriptor = FetchDescriptor<CategoryModel>(sortBy: [SortDescriptor(\.name, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving exercise: \(error.localizedDescription)")
        }
    }
    
    
}
