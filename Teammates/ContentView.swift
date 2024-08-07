//
//  ContentView.swift
//  Teammates
//
//  Created by Sachin Gurung on 7/30/24.
//

import SwiftUI

struct UserView: View {
    
    @State var selectedTab = 0
    
    var userName: String
    var userInitials: String
    var userActivities: [String]
    
    var body: some View {
        
        VStack{
            // User Profile Initial
            HStack{
                Circle().fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .overlay(Text(userInitials).foregroundColor(.white))
                
                // User Profile Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName).font(.title)
                    HStack(){
                        ForEach(userActivities, id: \.self){
                            activity in Text(activity).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
                    
                Spacer()
                
            }
        } .padding()
        
        Divider()
        
        TabView(selection: $selectedTab){
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }.tag(0)
            
            ToolsView().tabItem{
                Label("Tools", systemImage: "square.grid.3x3.fill")
            }.tag(1)
            
            MessagesView().tabItem{
                Label("Messages", systemImage: "message")
            }.tag(2)
            
            SettingsView().tabItem{
                Label("Settings", systemImage: "gearshape")
            }.tag(3)

        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("You have no activities\nJoin some teams, and tournaments")
                .multilineTextAlignment(.center).padding()
    }
}

struct ToolsView: View {
    var body: some View {
        Text("ToolsView")
    }
}

struct MessagesView: View {
    var body: some View {
        Text("MessagesView")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("SettingsView")
    }
}

struct ContentView: View {
    var body: some View {
        UserView(userName: "Carlson Jack", userInitials: "CJ", userActivities: ["Soccer", "Basketball"])
    }
}
