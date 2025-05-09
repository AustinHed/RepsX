//
//  ChartDataPoint.swift
//  RepsX
//
//  Created by Austin Hed on 3/6/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ChartDataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
