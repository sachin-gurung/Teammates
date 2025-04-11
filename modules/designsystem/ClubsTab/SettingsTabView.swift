//
//  SettingsTabView.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/10/25.
//

import SwiftUI

struct SettingsTabView: View {
    var club: Club
    
    var body: some View {
        VStack {
            Text("Settings for \(club.name)")
                .padding()
            Spacer()
        }
    }
}

//#Preview {
//    SettingsTabView()
//}
