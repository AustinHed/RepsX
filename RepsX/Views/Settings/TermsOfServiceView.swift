//
//  TermsOfServiceView.swift
//  RepsX
//
//  Created by Austin Hed on 4/3/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Effective Date: April 1st, 2025")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Introductory paragraph
                Text("Welcome to RepsX. By using this app, you agree to the following terms and conditions. Please read them carefully.")
                    .font(.body)
                
                // Section 1: Acceptance of Terms
                Text("1. Acceptance of Terms")
                    .font(.title2)
                    .bold()
                Text("By accessing and using RepsX, you accept and agree to be bound by these Terms of Service. If you do not agree, please do not use the app.")
                    .font(.body)
                
                // Section 2: Use of the App
                Text("2. Use of the App")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text("You must be at least 13 years old to use this app.")
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text("You are responsible for maintaining the confidentiality of your account and password.")
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text("You agree to use the app only for lawful purposes and in accordance with these Terms.")
                            .font(.body)
                    }
                }
                
                // Section 3: User-Provided Content
                Text("3. User-Provided Content")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        Text("Any content you submit or post within the app, including feedback or workout data, is your responsibility.")
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        Text("•")
                        Text("You grant RepsX a non-exclusive, worldwide, royalty-free license to use, modify, and display your content solely to provide the app's services.")
                            .font(.body)
                    }
                }
                
                // Section 4: Intellectual Property
                Text("4. Intellectual Property")
                    .font(.title2)
                    .bold()
                Text("All content, trademarks, and data on this app, including but not limited to text, graphics, logos, and software, is the property of RepsX or its licensors and is protected by intellectual property laws.")
                    .font(.body)
                
                // Section 5: Termination
                Text("5. Termination")
                    .font(.title2)
                    .bold()
                Text("We reserve the right to terminate or suspend your access to the app at any time, without notice, for conduct that we believe violates these Terms or is harmful to other users or the app.")
                    .font(.body)
                
                // Section 6: Disclaimer of Warranties
                Text("6. Disclaimer of Warranties")
                    .font(.title2)
                    .bold()
                Text("The app is provided on an \"as is\" and \"as available\" basis without warranties of any kind, either express or implied. RepsX does not guarantee that the app will be error-free or uninterrupted.")
                    .font(.body)
                
                // Section 7: Limitation of Liability
                Text("7. Limitation of Liability")
                    .font(.title2)
                    .bold()
                Text("In no event shall RepsX be liable for any indirect, incidental, special, consequential or punitive damages arising out of your use or inability to use the app.")
                    .font(.body)
                
                // Section 8: Changes to These Terms
                Text("8. Changes to These Terms")
                    .font(.title2)
                    .bold()
                Text("We may update these Terms of Service from time to time. Any changes will be posted within the app, and the \"Effective Date\" will be updated accordingly. Your continued use of the app after any such changes constitutes your acceptance of the new terms.")
                    .font(.body)
                
                // Section 9: Governing Law
                Text("9. Governing Law")
                    .font(.title2)
                    .bold()
                Text("These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions.")
                    .font(.body)
                
                // Section 10: Contact Us
                Text("10. Contact Us")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    Text("If you have any questions about these Terms, please contact us at:")
                        .font(.body)
                    Text("Email: RepsX@Outlook.com")
                        .font(.body)
                    Text("Address: 123 Main St, Chicago IL, 60657")
                        .font(.body)
                }
                
                Text("By using RepsX, you acknowledge that you have read and agree to these Terms of Service.")
                    .font(.body)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsOfServiceView()
        }
    }
}
