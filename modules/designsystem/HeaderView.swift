//
//  HeaderView.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/8/25.
//

import SwiftUI

struct HeaderView: View {
    var tabName: String
    
    @Binding var isMessageSheetPresented: Bool
    @Binding var isNotificationSheetPresented: Bool
    
    var body: some View {
        HStack {
            Text(tabName)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)
            
            Spacer()

            Button(action: {
                isMessageSheetPresented = true
            }) {
                Image(systemName: "message")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 10)
            
            Button(action: {
                isNotificationSheetPresented = true
            }) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(10)
        .padding(.horizontal)
        .background(Color(.systemGray4))
    }
}

//#Preview {
//    @State var isMessageSheetPresented = false
//    @State var isNotificationSheetPresented = false
//    return HeaderView(isMessageSheetPresented: $isMessageSheetPresented, isNotificationSheetPresented: $isNotificationSheetPresented)
//}
