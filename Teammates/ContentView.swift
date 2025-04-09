//
//  ContentView.swift
//  Teammates
//
//  Created by Sachin Gurung on 7/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedTab = 0
    @State private var isMessageSheetPresented = false
    @State private var isNotificationSheetPresented = false
    
    
    // Dummy profile data
    let userName = "Carlson Jack"
    let userInitials = "CJ"
    let userActivities = ["Soccer 7 v 7", "Soccer 11 v 11"]
    
    var tabName: String {
        switch selectedTab {
        case 0:
            return "Home"
        case 1:
            return "Clubs"
        case 2:
            return "Fixtures"
        case 3:
            return "Tools"
        case 4:
            return "Settings"
        default:
            return ""
        }
    }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray4
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        VStack(spacing: 0){
            // Header with Messages and Notifications
            HeaderView(
                tabName: tabName,
                isMessageSheetPresented: $isMessageSheetPresented,
                isNotificationSheetPresented: $isNotificationSheetPresented
            )
            
            Divider()
            
            TabView(selection: $selectedTab){
                HomeView(
                    userName: userName,
                    userInitials: userInitials,
                    userActivities: userActivities
                )
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }.tag(0)
                
                clubView().tabItem{
                    Label("Clubs", systemImage: "person.3")
                }.tag(1)
                
                FixturesView().tabItem{
                    Label("Fixtures", systemImage: "soccerball")
                }.tag(2)
                
                ToolsView().tabItem{
                    Label("Tools", systemImage: "wrench.and.screwdriver")
                }.tag(3)
                
                SettingsView().tabItem{
                    Label("Settings", systemImage: "gearshape")
                }.tag(4)
            }
        }
        .sheet(isPresented: $isMessageSheetPresented){
            MessageSheet()
        }
        .sheet(isPresented: $isNotificationSheetPresented){
            NotificationSheet()
        }
    }
}



















