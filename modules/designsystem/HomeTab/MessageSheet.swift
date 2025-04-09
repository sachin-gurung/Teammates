//
//  MessageSheet.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/8/25.
//

import SwiftUI

struct MessageSheet: View {
    var body: some View {
        VStack {
            Text("messages")
                .font(.title)
                .padding()
            Spacer()
            Text("You don't have any messages right now.")
                .font(.body)
                .padding()
            Spacer()
        }
        .presentationDetents([.medium, .large]) //Allows the sheet to be dragged to medium or large height
        .padding()
    }
}

#Preview {
    MessageSheet()
}
