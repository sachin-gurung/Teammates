//
//  FeedbackView.swift
//  Teammates
//
//  Created by Sachin Gurung on 2/11/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedbackText = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("We value your feedback!")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $feedbackText)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .padding()
                
                if isSubmitting {
                    ProgressView("Submitting...") // Show progress indicator
                        .padding()
                } else {
                    Button(action: submitFeedback) {
                        Text("Submit")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
            .navigationBarTitle("Feedback Form", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text("Your feedback has been submitted!"), dismissButton: .default(Text("Close"), action: {
                    presentationMode.wrappedValue.dismiss() // Close after success
                }))
            }
        }
    }
    
    private func submitFeedback() {
        guard !feedbackText.isEmpty else {
            return
        }
        
        isSubmitting = true // Show loading state
        
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser!.uid ?? "Anonymous"
        
        // Get the highest feedback ID and increment it
        db.collection("feedbacks_1").order(by: "feedbackId", descending: true).limit(to: 1).getDocuments { snapshot, error in
            var newFeedbackId = 1 // Default to 1 if no previous feedback exists
            
            if let documents = snapshot?.documents, let lastFeedback = documents.first {
                if let lastFeedbackId = lastFeedback.data()["feedbackId"] as? Int {
                    newFeedbackId = lastFeedbackId + 1
                }
            }
            
            // Feedback data
            let feedbackData: [String: Any] = [
                "feedbackId": newFeedbackId,
                "userId": userId,
                "feedback": feedbackText,
                "timestamp": Timestamp(date: Date()) // Store the date
                ]
            
            // Save feedback to Firestore
            db.collection("feedbacks_1").addDocument(data: feedbackData) { error in
                isSubmitting = false // Hide loading state
                
                if let error = error {
                    print ("Error submitting feedback: \(error.localizedDescription)")
                } else {
                    print("Feedback submitted successfully with ID \(newFeedbackId)")
                    showSuccessAlert = true // Show success alert
                }
            }
        }
    }
}

//import SwiftUI
//import FirebaseFirestore
//
//struct FeedbackView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var feedbackText = ""
//    @State private var isSubmitting = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .leading, spacing: 16) {
//                Text("Send us your feedback!")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//
//                TextEditor(text: $feedbackText)
//                    .frame(height: 150)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
//
//                Button(action: submitFeedback) {
//                    if isSubmitting {
//                        ProgressView()
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    } else {
//                        Text("Submit")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(feedbackText.isEmpty ? Color.gray : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//                .disabled(feedbackText.isEmpty || isSubmitting)
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Feedback")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Feedback"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//
//    func submitFeedback() {
//        isSubmitting = true
//        let db = Firestore.firestore()
//        let feedbackRef = db.collection("feedbacks_1").document() // Creates a new document
//
//        let feedbackData: [String: Any] = [
//            "id": feedbackRef.documentID,
//            "text": feedbackText,
//            "timestamp": Timestamp(date: Date())
//        ]
//
//        feedbackRef.setData(feedbackData) { error in
//            isSubmitting = false
//            if let error = error {
//                alertMessage = "Error saving feedback: \(error.localizedDescription)"
//                print("❌ Error saving feedback: \(error.localizedDescription)")
//            } else {
//                alertMessage = "Thank you for your feedback!"
//                print("✅ Feedback successfully submitted!")
//                feedbackText = "" // Clear the feedback input
//                dismiss() // Close the Feedback screen
//            }
//            showAlert = true
//        }
//    }
//}
//
//#Preview {
//    FeedbackView()
//}
