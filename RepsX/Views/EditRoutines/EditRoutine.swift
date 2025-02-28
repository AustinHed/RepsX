//
//  EditRoutine.swift
//  RepsX
//
//  Created by Austin Hed on 2/28/25.
//

import SwiftUI

struct EditRoutine: View {
    
    var routine: Routine
    
    var body: some View {
        NavigationStack{
            List {
                //start button
                Section {
                    Text("Start workout")
                }
                
                //Edit name
                Section{
                    Text("edit name")
                    Text("edit color")
                }
                
                //exercises
                Section{
                    Text("Hat")
                    Text("Hat")
                    Text("Hat")
                    Text("Hat")
                }
                
                //add exercise button
                Section{
                    Text("add exercise")
                }

            }
            .navigationTitle(routine.name)
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        //favorite routine
                        Button {
                            //favorite
                        } label: {
                            HStack{
                                Text("Favorite")
                                Spacer()
                                Image(systemName: "star.fill")
                            }
                        }

                        //reorder exercises
                        Button {
                            //reorder
                        } label: {
                            HStack{
                                Text("Reorder")
                                Spacer()
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                        
                        //delete specific routine
                        Button (role:.destructive) {
                            //delete
                        } label: {
                            HStack{
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        }
            
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
        }
        
    }
}

#Preview {
    let routine = Routine(name: "Test Routine")
    EditRoutine(routine: routine)
}
