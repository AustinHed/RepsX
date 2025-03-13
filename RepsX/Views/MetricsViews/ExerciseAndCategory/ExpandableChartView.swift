//
//  ExpandableChartView.swift
//  RepsX
//
//  Created by Austin Hed on 3/12/25.
//
import SwiftUI
import Foundation

struct ExpandableChartView<Content: View>: View {
    let title: String
    let content: Content
    
    // State to track if the chart is expanded or collapsed.
    @State private var isExpanded = false
    
    // Heights for collapsed and expanded states.
    let collapsedHeight: CGFloat
    let expandedHeight: CGFloat
    
    init(title: String,
         collapsedHeight: CGFloat = 100,
         expandedHeight: CGFloat = 400,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with title and an icon that rotates on toggle.
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(
                    UnevenRoundedRectangle(topLeadingRadius: 16,
                                           bottomLeadingRadius: 0,
                                           bottomTrailingRadius: 0,
                                           topTrailingRadius: 16
                                           )
                )
            }
            // The chart content.
            content
                .frame(height: isExpanded ? expandedHeight : collapsedHeight)
                .clipped()
                .animation(.easeInOut, value: isExpanded)
                .padding(.horizontal)
        }
        
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .padding(.horizontal)
    }
}
