//
//  ExpandableChartView.swift
//  RepsX
//
//  Created by Austin Hed on 3/12/25.
//
import SwiftUI
import Foundation

//TODO: update so that the chart can have 2 different collapsed sizes (smaller for Sets / Volume on Exercises)
enum ExpandableChartSize {
    case small
    case large
}

struct ExpandableChartView<Content: View>: View {
    let title: String
    let content: Content
    //chart type (sets, reps, etc.)
    var chartType:ChartFilter
    
    @Environment(\.themeColor) var themeColor
    
    // State to track if the chart is expanded or collapsed.
    @State private var isExpanded = false
    
    //currently selected datapoint
    @State private var selectedDataPoint: ChartDataPoint? = nil
    
    // Heights for collapsed and expanded states.
    let collapsedHeight: CGFloat
    let expandedHeight: CGFloat
    

    
    init(title: String,
         chartType: ChartFilter,
         collapsedHeight: CGFloat = 100,
         expandedHeight: CGFloat = 400,
         @ViewBuilder content: () -> Content)
    {
        self.title = title
        self.collapsedHeight = collapsedHeight
        self.expandedHeight = expandedHeight
        self.content = content()
        self.chartType = chartType
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
                    // Display selected data point details in the header if available. if not available, show the title
                    if let selected = selectedDataPoint {
                        //caseSwitch for the chartFilter
                        switch chartType {
                        case .exercise(_):
                            switch title {
                            case "Weight":
                                Text("\(selected.value, specifier: "%.2f") lb median set weight on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            case "Sets":
                                Text("\(selected.value, specifier: "%.0f") sets on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            case "Volume":
                                Text("\(selected.value, specifier: "%.2f") lbs of volume on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            //TODO: consider about distance and time
                            default:
                                Text("something went wrong")
                            }
                        case .category(_):
                            switch title {
                            case "Weight":
                                Text("\(selected.value, specifier: "%.2f") median set weight on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            case "Sets":
                                Text("\(selected.value, specifier: "%.0f") sets on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            case "Volume":
                                Text("\(selected.value, specifier: "%.2f") lbs of volume on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                    .font(.headline)
                            //TODO: consider about distance and time
                            default:
                                Text("something went wrong")
                            }
                        case .length:
                            Text("\(selected.value, specifier: "%.2f") minutes on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                .font(.headline)
                        case .volume:
                            Text("\(selected.value, specifier: "%.2f") lbs volume on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                .font(.headline)
                        case .sets:
                            Text("\(selected.value, specifier: "%.0f") sets on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                .font(.headline)
                        case .reps:
                            Text("\(selected.value, specifier: "%.0f") reps on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                .font(.headline)
                        case .intensity:
                            Text("\(selected.value, specifier: "%.2f") avg intensity on \(selected.date, format: .dateTime.month(.defaultDigits).day(.twoDigits))")
                                .font(.headline)
                        }
                    } else {
                        Text(title)
                            .font(.headline)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(themeColor)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(
                    UnevenRoundedRectangle(topLeadingRadius: 10,
                                           bottomLeadingRadius: 0,
                                           bottomTrailingRadius: 0,
                                           topTrailingRadius: 10
                                           )
                )
            }
            // The chart content.
            content
                .frame(height: isExpanded ? expandedHeight : collapsedHeight)
                .clipped()
                .animation(.easeInOut, value: isExpanded)
                .padding(.horizontal)
            // Capture the preference value from the chart.
                .onPreferenceChange(ChartDataPointPreferenceKey.self) { value in
                    withAnimation{
                        selectedDataPoint = value
                    }
                }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemBackground))
        )
        .padding(.horizontal)
    }
}
