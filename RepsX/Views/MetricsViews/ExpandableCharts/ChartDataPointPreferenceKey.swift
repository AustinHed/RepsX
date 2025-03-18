//
//  ChartDataPointPreferenceKey.swift
//  RepsX
//
//  Created by Austin Hed on 3/17/25.
//
import SwiftUI

struct ChartDataPointPreferenceKey: PreferenceKey {
    static var defaultValue: ChartDataPoint? = nil
    
    static func reduce(value: inout ChartDataPoint?, nextValue: () -> ChartDataPoint?) {
        // Use the latest non-nil value.
        if let next = nextValue() {
            value = next
        }
    }
}
