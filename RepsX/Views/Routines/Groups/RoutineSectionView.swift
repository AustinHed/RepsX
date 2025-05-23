//
//  RoutineSectionView.swift
//  RepsX
//
//  Created by Austin Hed on 5/23/25.
//

import SwiftUI
import SwiftData
import Foundation

struct SectionView: View {
    let title: String
    let routines: [Routine]
    @Binding var isExpanded: Bool
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        //.foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            // Grid Content
            if isExpanded {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(routines) { routine in
                        NavigationLink(value: routine) {
                            RoutineItem(routine: routine)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}
