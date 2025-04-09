//
//  NotificationSheet.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/8/25.
//

import SwiftUI

struct NotificationSheet: View {
    var body: some View {
        VStack {
            Text("Notification")
                .font(.title)
                .padding()
            Spacer()
            Text("No new notifications.")
                .font(.body)
                .padding()
            Spacer()
        }
        .presentationDetents([.medium, .large]) //Allows the sheet to be dragged to medium or large heights
        .padding()
    }
}

#Preview {
    NotificationSheet()
}
