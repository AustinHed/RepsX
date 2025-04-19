//
//  FeedbackJSON.swift
//  RepsX
//
//  Created by Austin Hed on 4/9/25.
//

import Foundation

// Define a structure representing the inner fields.
struct Feedback: Codable {
    let overallRating: Int
    let easeOfUseRating: Int
    let featuresRating: Int
    let feedbackCategory: String
    let feedbackText: String
    let emailAddress: String

    // Map our Swift property names to the expected JSON keys.
    enum CodingKeys: String, CodingKey {
        case overallRating = "OverallRating"
        case easeOfUseRating = "EaseOfUseRating"
        case featuresRating = "FeaturesRating"
        case feedbackCategory = "FeedbackCategory"
        case feedbackText = "FeedbackText"
        case emailAddress = "EmailAddress"
    }
}

// Define a structure representing a record which contains fields.
struct Record: Codable {
    let fields: Feedback
}

// Define the top level structure that contains an array of records.
struct APIRequest: Codable {
    let records: [Record]
}
