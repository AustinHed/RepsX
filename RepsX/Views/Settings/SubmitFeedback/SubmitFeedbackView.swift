//
//  SubmitFeedbackView.swift
//  RepsX
//
//  Created by Austin Hed on 4/3/25.
//

import SwiftUI
import SwiftData

enum FeedbackCategory: String, CaseIterable, Codable {
    case tracking = "Workout Tracking"
    case feature = "Feature Requests"
    case issues = "Technical Issues"
    case userExperience = "User Interface & Design"
    case content = "Content & Guidance"
    case other = "Other"
    
    var localizedName: LocalizedStringKey {LocalizedStringKey(rawValue)}
}

struct StarRatingSelector: View {
    // A rating of 0 means "NA", 1-5 are star ratings.
    @Binding var rating: Int
    @Environment(\.themeColor) var themeColor
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Star buttons
            ForEach(1...5, id: \.self) { star in
                Button {
                    // When tapping a star, set the rating accordingly.
                    rating = star
                } label: {
                    Image(systemName: rating >= star ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(themeColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            

        }
    }
}

struct SubmitFeedbackView: View {
    //Environment
    @Environment(\.themeColor) var themeColor
    @Environment(\.dismiss) var dismiss
    
    //Ratings
    @State private var overallRating: Int = 3
    @State private var easeRating: Int = 3
    @State private var featuresRating: Int = 3
    
    //Commentary
    @State private var feedbackCategory: FeedbackCategory = .other
    @State private var commentary: String = ""
    
    //Email
    @State private var email: String = ""
    private var emailIsValid: Bool {
        if !emailValidation(email: email) && !email.isEmpty {
         return false
        } else {
            return true
        }
    }
    
    //Focus states
    @FocusState private var emailFocusState: Bool
    @FocusState private var feedbackFocusState: Bool
    
    //Other
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {

        Form {
            ratingsSection
            
            feedbackSection
            
            emailSection
            
            submitButton
        }
        .navigationTitle("Feedback")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Feedback Submitted"),
                message: Text("Thank you for your feedback!"),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
        .scrollContentBackground(.hidden)
        .background(CustomBackground(themeColor: themeColor))
        .tint(themeColor)
    }
    
    
}

//MARK: Email validation
extension SubmitFeedbackView {
    func emailValidation(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}

//MARK: Ratings Section
extension SubmitFeedbackView {
    var ratingsSection: some View {
        Section(header:
                    HStack{
            Text("Rating")
                .font(.headline)
                .bold()
                .foregroundStyle(.black)
                .textCase(nil)
            Spacer()
        }
            .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
        ) {
            HStack{
                Text("Overall")
                Spacer()
                StarRatingSelector(rating: $overallRating)
            }
            
            HStack{
                Text("Ease of Use")
                Spacer()
                StarRatingSelector(rating: $easeRating)
            }
            
            HStack{
                Text("Available Features")
                Spacer()
                StarRatingSelector(rating: $featuresRating)
            }
        }
    }
}

//MARK: Feedback Section
extension SubmitFeedbackView {
    var feedbackSection: some View {
        Section {
            Picker("Category", selection: $feedbackCategory) {
                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                    Text(category.localizedName)
                }
            }
            ZStack{
                TextEditor(text: $commentary)
                    .frame(minHeight: 50)
                    .submitLabel(.done)
                    .onChange(of: commentary) { _ in
                        if commentary.last?.isNewline == .some(true) {
                            commentary.removeLast()
                            feedbackFocusState = false
                        }
                    }
                    .focused($feedbackFocusState)
                
                if commentary.isEmpty {
                    VStack{
                        HStack{
                            Text("Commentary (optional)")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        } header: {
            HStack{
                Text("Feedback")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
            
        } footer: {
            Text("Please do not provide personal information such as your name, address, or credit card details.")
        }
    }
}

//MARK: Email Section
extension SubmitFeedbackView {
    var emailSection: some View {
        Section {
            TextField("Email Address (optional)", text: $email)
                .onChange(of: email) { _ in
                    if email.last?.isNewline == .some(true) {
                        email.removeLast()
                        emailFocusState = false
                    }
                }
                .submitLabel(.done)
                .keyboardType(.emailAddress)
                .focused($emailFocusState)
        } header: {
            HStack{
                Text("Custom Categories")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.black)
                    .textCase(nil)
                Spacer()
            }
                .listRowInsets(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
        } footer: {
            Text("By including your email address, you agree that we may contact you regarding your feedback.")
        }
    }
}

//MARK: Submit Button
extension SubmitFeedbackView {
    var submitButton: some View {
        Section {
            Button {
                Task {
                    do {
                        try await submitFeedback(overallRatings: overallRating, easeRating: easeRating, featureRating: featuresRating, feedbackCategory: feedbackCategory.rawValue, commentary: commentary, email: email)
                        isSubmitting = false
                        showAlert = true
                    } catch {
                        print("error submitting feedback: \(error)")
                    }
                }
            } label: {
                HStack{
                    Spacer()
                    Text("Submit")
                    Spacer()
                }
            }
            .disabled(isSubmitting)
            .disabled(!emailIsValid)
        }
        
        
    }
    private var airtableApiKey: String {
        get {
            //1 - check if there is a plist file
            guard let filePath = Bundle.main.path(forResource:"AirtableInfo", ofType: "plist") else {
                fatalError("Coudln't find AirtableInfo.plist")
            }
            
            //2 - fetch the API key
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey:"API_KEY") as? String else {
                fatalError("Couldn't find 'API_KEY' in AirtableInfo.plist")
            }
            //3 - return the fetched key
            return value
        }
    }
    
    private func submitFeedback(overallRatings: Int, easeRating: Int, featureRating: Int, feedbackCategory: String, commentary: String, email: String) async throws {
        //validate the URL
        guard let url = URL(string: "https://api.airtable.com/v0/app0eTpiGCGSqmXCz/tbliwhZWxzueaqUop") else {
            throw URLError(.badURL)
        }
        
        //create the object to pass
        let feedback = Feedback(
            overallRating: overallRatings,
            easeOfUseRating: easeRating,
            featuresRating: featureRating,
            feedbackCategory: feedbackCategory,
            feedbackText: commentary,
            emailAddress: email
        )
        
        //wrap the created object in a "Record". Both are custom structs, specific to the Airtable call
        let record = Record(fields: feedback)
        let requestBody = APIRequest(records: [record])
        
        //create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(airtableApiKey, forHTTPHeaderField: "Authorization")
        
        //encode the request as JSON
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        //make the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //check the response, and error if it failed
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        print("API call response: \(data)")
    }
}

#Preview {
    NavigationStack{
        SubmitFeedbackView()
    }
}
