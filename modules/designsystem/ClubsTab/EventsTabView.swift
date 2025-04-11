//
//  EventsTabView.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/10/25.
//

import SwiftUI

struct EventsTabView: View {
    var club: Club
    
    var body: some View {
        Text("Events for \(club.name)")
            .padding()
        Spacer()
    }
}

//#Preview {
//    EventsTabView()
//}
