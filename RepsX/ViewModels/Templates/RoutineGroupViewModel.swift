//
//  RoutineGroupViewModel.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class RoutineGroupViewModel {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //add
    func addRoutineGroup(name: String) {
        let newRoutineGroup = RoutineGroup(name: name, routines: [])
        modelContext.insert(newRoutineGroup)
        save()
    }
    
    //delete
    func deleteRoutineGroup(_ routineGroup: RoutineGroup) {
        for routine in routineGroup.routines {
            routine.group = nil
        }
        
        DispatchQueue.main.async {
            self.modelContext.delete(routineGroup)
            self.save()
        }
    }
    
    //update
    func updateRoutineGroup(_ routineGroup: RoutineGroup, newName: String? = nil) {
        if let newName = newName {
            routineGroup.name = newName
        }
        save()
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
