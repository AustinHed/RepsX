import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Effective Date: April 1st, 2025")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Introductory text
                Text("Thank you for choosing to be part of our community at RepsX (\"we\", \"us\", or \"our\"). This Privacy Policy explains how we handle information that you provide to us when you use our mobile application (the \"App\").")
                    .font(.body)
                
                // Section 1
                Text("1. Information We Collect")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**Workout Data:**")
                                .font(.headline)
                            Text("We only collect data that you voluntarily provide regarding your workouts. This may include details such as workout type, duration, intensity, and any other information you choose to enter.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**No Additional Data Collection:**")
                                .font(.headline)
                            Text("We do not collect any other personal data beyond what is necessary for the App’s functionality.")
                                .font(.body)
                        }
                    }
                }
                
                // Section 2
                Text("2. How We Use Your Information")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**Functionality:**")
                                .font(.headline)
                            Text("The data you provide is used solely to power the features of the App. For example, your workout data is used to display your workout history and track your progress.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**Local Storage:**")
                                .font(.headline)
                            Text("All data is stored locally on your device. We do not transmit or upload your data to any external servers.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**No Marketing:**")
                                .font(.headline)
                            Text("We do not use your workout data for marketing, advertising, or any other purposes beyond the operation of the App.")
                                .font(.body)
                        }
                    }
                }
                
                // Section 3
                Text("3. Data Sharing and Third Parties")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**No Sharing:**")
                                .font(.headline)
                            Text("We do not share your data with any third parties.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**No Third-Party Analytics:**")
                                .font(.headline)
                            Text("Since your data is stored only on your device, it is not accessed by any external services or analytics providers.")
                                .font(.body)
                        }
                    }
                }
                
                // Section 4
                Text("4. Data Security")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**Local Security:**")
                                .font(.headline)
                            Text("Your data is stored locally on your device. While we take reasonable measures to protect your data, please note that no electronic storage method is 100% secure.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**User Responsibility:**")
                                .font(.headline)
                            Text("We encourage you to maintain the security of your device to further protect your personal information.")
                                .font(.body)
                        }
                    }
                }
                
                // Section 5
                Text("5. Your Rights and Choices")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**Control Over Data:**")
                                .font(.headline)
                            Text("Since all data is stored locally, you have full control over your information. You may delete your data at any time by uninstalling the App or clearing the data from your device.")
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("•")
                        VStack(alignment: .leading) {
                            Text("**No Account Required:**")
                                .font(.headline)
                            Text("Our App does not require you to create an account or provide additional personal information.")
                                .font(.body)
                        }
                    }
                }
                
                // Section 6
                Text("6. Changes to This Privacy Policy")
                    .font(.title2)
                    .bold()
                Text("We may update our Privacy Policy from time to time. Any changes will be posted within the App, and the \"Effective Date\" will be updated accordingly. We encourage you to review this Privacy Policy periodically.")
                    .font(.body)
                
                // Section 7
                Text("7. Contact Us")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    Text("If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:")
                        .font(.body)
                    Text("Email: RepsX@Outlook.com")
                        .font(.body)
                    Text("Address: 123 Main St, Chicago IL, 60657")
                        .font(.body)
                }
                
                // Final note
                Text("By using RepsX, you acknowledge that you have read and understand this Privacy Policy. If you do not agree with our policies, please do not use the App.")
                    .font(.body)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .safeAreaInset(edge: .bottom) {
            // Add extra space (e.g., 100 points)
            Color.clear.frame(height: 100)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
