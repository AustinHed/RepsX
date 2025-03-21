//
//  CategoryViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 2/26/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class CategoryViewModel {
    
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
    func deleteCategory(_ category: CategoryModel) {
        //first, delete category
        //modelContext.delete(category)
        //instead of deleting, we're just hiding it
        category.isHidden = true
        //then, save
        save()
    }
    
    //update
    func updateCategory(_ category: CategoryModel, newName:String? = nil) {
        if let newName = newName {
            category.name = newName
        }
        save()
    }
    
    //fetch
    func fetchCategories() -> [CategoryModel] {
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate:#Predicate<CategoryModel> { category in
                category.isHidden == false
            },
            sortBy: [SortDescriptor(\.name, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    //save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving categories: \(error.localizedDescription)")
        }
    }
}
