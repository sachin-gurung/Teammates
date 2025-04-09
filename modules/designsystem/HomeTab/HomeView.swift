// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct HomeView: View {
    var userName: String
    var userInitials: String
    var userActivities: [String]
    
    public init(userName: String, userInitials: String, userActivities: [String]) {
        self.userName = userName
        self.userInitials = userInitials
        self.userActivities = userActivities
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle().fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .overlay(Text(userInitials)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.title)
                        .fontWeight(.semibold)
                    HStack() {
                        ForEach(userActivities, id: \.self) { activity in
                            Text(activity)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            Spacer()
            }
            .padding(.horizontal)
            Divider()
            Spacer()
            
            Text("You have no activities\nJoin some teams, and tournaments to get started!")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
    }
}

