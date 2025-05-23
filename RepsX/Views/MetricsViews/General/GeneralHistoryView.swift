//
//  GeneralHistoryView.swift
//  RepsX
//
//  Created by Austin Hed on 3/13/25.
//

import SwiftUI

struct GeneralHistoryView: View {
    
    //all datapoints
    let dataPoints: [ChartDataPoint]
    
    //switch
    let filter: ChartFilter
    
    // A date formatter for display purposes.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    //theme
    @Environment(\.themeModel) var theme
    @Environment(\.colorScheme) var colorScheme
    var primaryColor: Color {
        return theme.color(for: colorScheme)
    }
    
    var body: some View {
        // List format below the chart.
        // You can use List or a ScrollView with LazyVStack for custom styling.
        List(dataPoints.sorted {$0.date > $1.date}, id: \.date) { dataPoint in
            rowView(for: dataPoint)
        }
        .navigationTitle("History: \(filter.navigationTitle)")
        //MARK: Background
        .scrollContentBackground(.hidden)
        .background(
            CustomBackground(primaryColor: primaryColor)
        )
    }
}

//MARK: Rows
extension GeneralHistoryView {
    /// Returns a view for a given SetHistory record.
    private func rowView(for record: ChartDataPoint) -> some View {
        HStack {
            
            // Date column.
            VStack(alignment: .leading) {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(record.date, format: Date.FormatStyle.dateTime
                        .month(.twoDigits)
                        .day(.twoDigits)
                        .year())
            }
            .frame(width: 120, alignment: .leading)
            Spacer()
            
            // Value column.
            switch filter {
                
            case .length:
                VStack(alignment: .leading) {
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f", record.value))
                }
                .frame(width: 100, alignment: .leading)
            case .volume:
                VStack(alignment: .leading) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f", record.value))
                }
                .frame(width: 100, alignment: .leading)
            case .sets:
                VStack(alignment: .leading) {
                    Text("Sets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", record.value))
                }
                .frame(width: 100, alignment: .leading)
            case .reps:
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f", record.value))
                }
                .frame(width: 100, alignment: .leading)
            case .intensity:
                VStack(alignment: .leading) {
                    Text("Average Intensity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f", record.value))
                }
                .frame(width: 100, alignment: .leading)
                
            default:
                //this shouldn't happen
                Text("something went wrong")
            }
            
            
        }
        .padding(.horizontal, 5)
    }
}
