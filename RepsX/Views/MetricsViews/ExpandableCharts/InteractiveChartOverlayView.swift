//
//  InteractiveChartOverlayView.swift
//  RepsX
//
//  Created by Austin Hed on 3/17/25.
//

import SwiftUI
import Charts

/// A reusable view modifier to add a gesture overlay to a Chart.
struct InteractiveChartOverlayView<DataPoint>: ViewModifier {
    let data: [DataPoint]
    @Binding var selectedDataPoint: DataPoint?
    /// A closure that returns the x-axis value (for example, Date) from a DataPoint.
    let xValue: (DataPoint) -> Date

    func body(content: Content) -> some View {
        content
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        // Find the nearest data point based on the x-axis value.
                                        if let nearest = data.min(by: {
                                            abs(xValue($0).timeIntervalSince(date)) < abs(xValue($1).timeIntervalSince(date))
                                        }) {
                                            selectedDataPoint = nearest
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    selectedDataPoint = nil
                                }
                        )
                }
            }
    }
}

extension View {
    /// Easily attach the interactive overlay to any Chart.
    func interactiveChartOverlay<DataPoint>(
        data: [DataPoint],
        selectedDataPoint: Binding<DataPoint?>,
        xValue: @escaping (DataPoint) -> Date
    ) -> some View {
        self.modifier(InteractiveChartOverlayView(data: data, selectedDataPoint: selectedDataPoint, xValue: xValue))
    }
}
