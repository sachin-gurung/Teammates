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
        ZStack{
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
            
        }
       
        Divider()
        
        TabView(selection: $selectedTab){
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }.tag(0)
            
            GroupView().tabItem{
                Label("Group", systemImage: "person.3")
            }.tag(1)
            
//            GamesView().tabItem{
//                Label("Games", systemImage: "figure.indoor.soccer")
//            }.tag(2)
            
            GamesView().tabItem{
                Label("Games", systemImage: "figure.indoor.soccer")
            }.tag(2)
            
            FieldsView().tabItem{
                Label("Fields", systemImage: "sportscourt.fill")
            }.tag(3)
            
            SettingsView().tabItem{
                Label("Settings", systemImage: "gearshape")
            }.tag(4)
        }
        .background(Color(.systemGray6))
    }
}

struct ContentView: View {
    var body: some View {
        UserView(userName: "Carlson Jack", userInitials: "CJ", userActivities: ["Soccer", "Basketball"])
    }
}

















