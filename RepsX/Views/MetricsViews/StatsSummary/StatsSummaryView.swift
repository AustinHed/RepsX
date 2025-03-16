import SwiftUI

struct StatsSummaryView: View {
    let dataPoints: [ChartDataPoint]
    
    let minDataPoints: [ChartDataPoint]?
    let maxDataPoints: [ChartDataPoint]?
    
    let filter: ChartFilter
    let lookback: LookbackOption //if allTime, then 0
    
    init(dataPoints: [ChartDataPoint],
         minDataPoints: [ChartDataPoint]? = nil,
         maxDataPoints: [ChartDataPoint]? = nil,
         filter: ChartFilter,
         lookback: LookbackOption) {
        self.dataPoints = dataPoints
        self.minDataPoints = minDataPoints
        self.maxDataPoints = maxDataPoints
        self.filter = filter
        self.lookback = lookback
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            //Summary text
            VStack (alignment:.leading){
                humanReadableSummary
                    .padding(.bottom)
                
                // Overall Total
                //this should be a computed var
                humanReadableTotal
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            
            //Min Max Avg Med
            HStack {
                // Minimum (excluding zeros)
                VStack(alignment: .leading) {
                    Text("Min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let minVal = currentMin {
                        Text("\(minVal, specifier: "%.1f")")
                            .font(.headline)
                    } else {
                        Text("-")
                            .font(.headline)
                    }
                }
                Spacer()
                // Maximum
                VStack(alignment: .leading) {
                    Text("Max")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let maxVal = currentMax {
                        Text("\(maxVal, specifier: "%.1f")")
                            .font(.headline)
                    } else {
                        Text("-")
                            .font(.headline)
                    }
                }
                Spacer()
                //average
                VStack(alignment: .leading) {
                    Text("Average")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(currentAverage, specifier: "%.1f")")
                        .font(.headline)
                }
                Spacer()
                //median
                VStack(alignment: .leading) {
                    Text("Median")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let medianVal = currentMedian {
                        Text("\(medianVal, specifier: "%.1f")")
                            .font(.headline)
                    } else {
                        Text("-")
                            .font(.headline)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)

            
        }
    }
}

// MARK: Calendar Helpers
extension StatsSummaryView {
    
    var calendar: Calendar { Calendar.current }
    var today: Date { calendar.startOfDay(for: Date()) }
    
    /// Returns the start of the current period based on the lookback option.
    var currentPeriodStart: Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(lookback.rawValue - 1), to: today) ?? today)
    }
}

// MARK: Filtered Data Points
extension StatsSummaryView {
    /// Data points falling within the current period.
    var currentDataPoints: [ChartDataPoint] {
        
        if lookback.rawValue != 0 {
            print ("using limited time")
            return dataPoints.filter { point in
                point.date >= currentPeriodStart && point.date <= today
            }
            
        } else {
            
            let oldestDataPointDate = dataPoints.min(by: { $0.date < $1.date })?.date ?? Date()
            print("using all time")
            return dataPoints.filter { point in
                point.date >= oldestDataPointDate && point.date <= today
            }
        }
        
    }
}

// MARK:  Aggregated Metrics
extension StatsSummaryView {
    /// Total value of the current period.
    var currentTotal: Double {
        currentDataPoints.reduce(0) { $0 + $1.value }
    }
    
    /// Average value of the current period.
    var currentAverage: Double {
        guard !currentDataPoints.isEmpty else { return 0 }
        return currentDataPoints.reduce(0) { $0 + $1.value } / Double(currentDataPoints.count)
    }
    
    /// Median value of the current period.
    var currentMedian: Double? {
        let sortedValues = currentDataPoints.map { $0.value }.sorted()
        guard !sortedValues.isEmpty else { return nil }
        let count = sortedValues.count
        if count % 2 == 1 {
            return sortedValues[count / 2]
        } else {
            return (sortedValues[count / 2 - 1] + sortedValues[count / 2]) / 2
        }
    }
    
    /// Computes the percentage change for the current period.
    /// For periods under 30 days (or with fewer than 6 data points), it compares the first and last values.
    /// For longer periods, it compares the average of the first 3 values with the average of the last 3 values.
    var currentPeriodChange: Double {
        let sortedPoints = currentDataPoints.sorted { $0.date < $1.date }
        guard let first = sortedPoints.first, let last = sortedPoints.last, first.value != 0 else { return 0 }
        
        let baseline: Double
        let ending: Double
        if lookback.rawValue < 30 || sortedPoints.count < 6 {
            baseline = first.value
            ending = last.value
        } else {
            let firstThree = sortedPoints.prefix(3)
            let lastThree = sortedPoints.suffix(3)
            baseline = firstThree.reduce(0) { $0 + $1.value } / Double(firstThree.count)
            ending = lastThree.reduce(0) { $0 + $1.value } / Double(lastThree.count)
        }
        return ((ending - baseline) / baseline) * 100
    }
    
    /// The minimum value from the current period, excluding zeros.
    var currentMin: Double? {
        let nonZeroValues = currentDataPoints.map { $0.value }.filter { $0 != 0 }
        if minDataPoints != nil {
            return minDataPoint.value
        } else {
            return nonZeroValues.min()
        }
        
    }
    
    /// The maximum value from the current period.
    var currentMax: Double? {
        if maxDataPoints != nil {
            return maxDataPoint.value
        } else {
            return currentDataPoints.map { $0.value }.max()
        }
    }
}

//MARK: Min and Max values + associated date
///used for the candlesticks
extension StatsSummaryView {
    var minDataPoint: (value: Double, date: String) {
        // Find the ChartDataPoint with the minimum value.
        guard let minPoint = minDataPoints?.min(by: { $0.value < $1.value }) else {
            return (0, "N/A")
        }
        
        // Format the date as a string.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: minPoint.date)
        
        return (minPoint.value, dateString)
    }
    
    var maxDataPoint: (value: Double, date: String) {
        // Find the ChartDataPoint with the minimum value.
        guard let minPoint = maxDataPoints?.max(by: { $0.value < $1.value }) else {
            return (0, "N/A")
        }
        
        // Format the date as a string.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: minPoint.date)
        
        return (minPoint.value, dateString)
    }
    
}

// MARK: Summary & data trends
extension StatsSummaryView {
    
    /// A human-readable version of the metric name (used in the summary sentence).
    var humanReadableMetric: String {
        switch filter {
        case .length:
            return "daily workout duration"
        case .volume:
            return "daily lift volume"
        case .sets:
            return "daily sets"
        case .reps:
            return "daily reps"
        case .intensity:
            return "daily set intensity"
        case .category(let category):
            return "\(category.name) weight"
        case .exercise(let exercise):
            return "\(exercise.name) weight"
        default:
            return "metric"
        }
    }
    
    /// Returns a human-readable summary sentence for the current period.
    var humanReadableSummary: Text {
        let sortedPoints = currentDataPoints.sorted { $0.date < $1.date }
        guard let first = sortedPoints.first, let last = sortedPoints.last, first.value != 0 else {
            return Text("Not enough data to compute a trend.")
        }
        
        let baseline: Double
        let ending: Double
        if lookback.rawValue < 30 || sortedPoints.count < 6 {
            baseline = first.value
            ending = last.value
        } else {
            let firstThree = sortedPoints.prefix(3)
            let lastThree = sortedPoints.suffix(3)
            baseline = firstThree.reduce(0) { $0 + $1.value } / Double(firstThree.count)
            ending = lastThree.reduce(0) { $0 + $1.value } / Double(lastThree.count)
        }
        
        let direction = ending >= baseline ? "increased" : "decreased"
        let changePercent = abs(((ending - baseline) / baseline) * 100)
        let baselineString = String(format: "%.1f", baseline)
        let endingString = String(format: "%.1f", ending)
        let changePercentString = String(format: "%.1f", changePercent)
        
        // If the value increased, display in green; if decreased, in red.
        let changeColor: Color = (ending >= baseline) ? .green : .red
        
        //metric value
        var metricValue: String {
            switch filter {
            case .length:
                return "mins"
            case .volume:
                return "lbs"
            case .sets:
                return "sets"
            case .reps:
                return "reps"
            case .intensity:
                return "units"
            case .category(_):
                return "lbs"
            case .exercise(_):
                return "lbs"
            default:
                return ""
            }
        }
        
        /// Returns the correct verb ("has" or "have") based on the filter type.
        var verb: Text {
            switch filter {
            case .sets, .reps:
                return Text(" have ")
            default:
                return Text(" has ")
            }
        }
        
        if lookback.rawValue == 0 {
            //all time
            return Text("Your ")
            + Text("All-Time").bold().foregroundColor(.blue)
            + Text(" average ")
            + Text("\(humanReadableMetric)")
            + verb
            + Text("\(direction) ").bold().foregroundColor(changeColor)
            + Text("\(changePercentString)%").bold().foregroundColor(changeColor)
            + Text(", from ")
            + Text("\(baselineString) ").bold().foregroundStyle(.blue)
            + Text(metricValue)
            + Text(" to ")
            + Text("\(endingString) ").bold().foregroundStyle(.blue)
            + Text(metricValue)
            + Text(".")
        } else {
            return Text("Over the last ")
                + Text("\(lookback.rawValue) days").bold().foregroundStyle(.blue)
                + Text(" your average ")
                + Text("\(humanReadableMetric)")
                + verb
                + Text("\(direction) ").bold().foregroundColor(changeColor)
                + Text("\(changePercentString)%").bold().foregroundColor(changeColor)
                + Text(", from ")
                + Text("\(baselineString) ").bold().foregroundStyle(.blue)
                + Text(metricValue)
                + Text(" to ")
                + Text("\(endingString) ").bold().foregroundStyle(.blue)
                + Text(metricValue)
                + Text(".")
        }
        
    }
}

//MARK: Human readable total / set PR
extension StatsSummaryView {
    /// Formats the start date of the current period as "MM/dd/yy".
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: currentPeriodStart)
    }
    
    var humanReadableTotal: Text {
        switch filter {
        
        case .length:
            if lookback.rawValue == 0 {
                //all time
                return Text("Your")
                + Text(" All-Time ").bold().foregroundStyle(.blue)
                + Text(" minutes of exercise logged is ")
                + Text("\(currentTotal, specifier: "%.0f") minutes.").bold().foregroundStyle(.blue)
            } else {
                //limited time
                return Text("Since ")
                + Text("\(formattedStartDate)").bold().foregroundStyle(.blue)
                    + Text(", you logged ")
                    + Text("\(currentTotal, specifier: "%.0f") minutes of exercise.").bold().foregroundStyle(.blue)
                
            }
        
        case .sets:
            if lookback.rawValue == 0 {
                //all time
                return Text("Your")
                + Text(" All-Time ").bold().foregroundStyle(.blue)
                + Text(" total sets completed is ")
                + Text("\(currentTotal, specifier: "%.0f") sets.").bold().foregroundStyle(.blue)
            } else {
                //limited time
                return Text("Since ")
                    + Text("\(formattedStartDate)").bold().foregroundStyle(.blue)
                    + Text(", you completed ")
                    + Text("\(currentTotal, specifier: "%.0f") sets.").bold().foregroundStyle(.blue)
                
            }
        
        case .reps:
            if lookback.rawValue == 0 {
                //all time
                return Text("Your")
                + Text(" All-Time ").bold().foregroundStyle(.blue)
                + Text(" total reps completed is ")
                + Text("\(currentTotal, specifier: "%.0f") reps.").bold().foregroundStyle(.blue)
                
            } else {
                //limited time
                return Text("Since ")
                    + Text("\(formattedStartDate)").bold().foregroundStyle(.blue)
                    + Text(", you completed ")
                    + Text("\(currentTotal, specifier: "%.0f") reps.").bold().foregroundStyle(.blue)
                
            }
        
        case .volume:
            if lookback.rawValue == 0 {
                //all time
                return Text("Your")
                + Text(" All-Time ").bold().foregroundStyle(.blue)
                + Text(" total lift volume is ")
                + Text("\(currentTotal, specifier: "%.0f") lbs of volume.").bold().foregroundStyle(.blue)
                
            } else {
                //limited time
                return Text("Since ")
                    + Text("\(formattedStartDate)").bold().foregroundStyle(.blue)
                    + Text(", you lifted ")
                    + Text("\(currentTotal, specifier: "%.0f") lbs of volume.").bold().foregroundStyle(.blue)
                
            }
        
        case .intensity:
            // For intensity, using average because a total doesn't make sense.
            if lookback.rawValue == 0 {
                // all time
                return Text("Your")
                + Text(" All-Time ").bold().foregroundStyle(.blue)
                + Text(" average intensity is ")
                + Text("\(currentAverage, specifier: "%.1f")").bold().foregroundStyle(.blue)
                + Text("units.")
                
            } else {
                //limited time
                return Text("Since ")
                + Text("\(formattedStartDate)").bold().foregroundStyle(.blue)
                + Text(", your average intensity was ")
                + Text("\(currentAverage, specifier: "%.1f")").bold().foregroundStyle(.blue)
                + Text(".")
            }
                
        case .category(let category):
            if lookback.rawValue == 0 {
                return Text("Your ")
                + Text("All-Time ").bold().foregroundStyle(.blue)
                + Text("\(category.name) PR ")
                + Text("is ")
                + Text("\(maxDataPoint.value, specifier: "%.1f") lbs").bold().foregroundStyle(.blue)
                + Text(", achieved on ")
                + Text("\(maxDataPoint.date)").bold().foregroundStyle(.blue)
            } else {
                return Text("Your ")
                + Text("\(lookback.rawValue)-day ").bold().foregroundStyle(.blue)
                + Text("\(category.name) PR ")
                + Text("was ")
                + Text("\(maxDataPoint.value, specifier: "%.1f") lbs").bold().foregroundStyle(.blue)
                + Text(", achieved on ")
                + Text("\(maxDataPoint.date)").bold().foregroundStyle(.blue)
            }
        
        case .exercise(let exercise):
            if lookback.rawValue == 0 {
                return Text("Your ")
                + Text("All-Time ").bold().foregroundStyle(.blue)
                + Text("\(exercise.name) PR ")
                + Text("is ")
                + Text("\(maxDataPoint.value, specifier: "%.1f") lbs").bold().foregroundStyle(.blue)
                + Text(", achieved on ")
                + Text("\(maxDataPoint.date)").bold().foregroundStyle(.blue)
            } else {
                return Text("Your ")
                + Text("\(lookback.rawValue)-day ").bold().foregroundStyle(.blue)
                + Text("\(exercise.name) PR ")
                + Text("was ")
                + Text("\(maxDataPoint.value, specifier: "%.1f") lbs").bold().foregroundStyle(.blue)
                + Text(", achieved on ")
                + Text("\(maxDataPoint.date)").bold().foregroundStyle(.blue)
            }
        
        default:
            return Text("No metric selected.")
        }
    }
}

