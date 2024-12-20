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
            
            GamesView().tabItem{
                Label("Games", systemImage: "figure.indoor.soccer")
            }.tag(1)
            
            FieldsView().tabItem{
                Label("Fields", systemImage: "sportscourt.fill")
            }.tag(2)
            
            SettingsView().tabItem{
                Label("Settings", systemImage: "gearshape")
            }.tag(3)
        }
        .background(Color(.systemGray6))
    }
}

struct HomeView: View {
    var body: some View {
        Text("You have no activities\nJoin some teams, and tournaments")
                .multilineTextAlignment(.center).padding()
    }
}

struct GroupView: View {
    var body: some View {
        Text("You have no groups\nCreate some groups")
            .multilineTextAlignment(.center).padding()
    }
}

struct GamesView: View {
    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing: 20) {
                Text("Organize")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                
                HStack(spacing: 20){
                        NavigationLink(destination: MatchView()){
                            ToolButton(title: "Match")
                        }
                        NavigationLink(destination: TournamentPageView()){
                            ToolButton(title: "Tournament")
                        }
                }
                .padding(.horizontal)
                
                Text("Field")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                
                HStack(spacing: 20){
                    NavigationLink(destination: ManageFieldView()){
                        ToolButton(title:"Manage Field")
                    }
                    
                    NavigationLink(destination: FieldsView()){
                        ToolButton(title: "Fields")
                    }
                }
                .padding(.horizontal)
                
                Text("Groups")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 20){
                        NavigationLink(destination: TeamView()){
                            ToolButton(title: "Team")
                        }
                        
                        NavigationLink(destination: ClubView()){
                            ToolButton(title: "Club")
                        }
                        
                        NavigationLink(destination: GroupView()){
                            ToolButton(title: "Group")
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer() // Add a Spacer() at the bottom to push the content to the top
            }
        }
    }
}

struct FieldsView: View {
    var body: some View {
        Text("FieldsView")
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

struct ToolButton: View {
    var title: String
    
    var body: some View{
        Text(title)
            .frame(width: 150, height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

struct MatchView: View{
    var body: some View{
        Text("Match View")
            .font(.largeTitle)
            .navigationTitle("Match")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct Tournament: Identifiable {
    var id = UUID()
    var name: String
    var league: String
    var teams: Int
}

struct TournamentPageView: View{
    @State private var tournaments: [Tournament] = [Tournament(name: "Tournament 1", league: "League 1", teams: 1), Tournament(name: "Tournament 2", league: "League 2", teams: 2), Tournament(name: "Tournament 3", league: "League 3", teams: 3)]
    
    var body: some View{
        ZStack {
            ScrollView {
                VStack {
                    ForEach(tournaments, id: \.id) { tournament in
                        NavigationLink(destination: TournamentDetailView(Tournament: tournament)) {
                            VStack(alignment: .leading){
                                Text(tournament.name)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(tournament.league)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(tournament.teams) Teams")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    FloatingAddButton(action: addNewTournament)
                }
            }
        }
        
        // Add the Floating Add button at the bottom right above TabView
        VStack{
            Spacer()
            FloatingAddButton(action: {
                // Add action for the Floating Add button here
            })
        }
        .padding(.trailing, 16)
        .padding(.bottom, 60)
    }
    
    private func addNewTournament() {
        // Logic to add new tournament (show a form)
        let newTournament = Tournament(name: "New Tournament", league: "New League", teams: 1)
        tournaments.append(newTournament)
    }
}

struct FloatingAddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .shadow(radius: 20)
                .clipShape(Rectangle())
        }
    }
}



struct TournamentDetailView: View{
    var Tournament: Tournament
    var body: some View{
        Text("Tournament Detail View")
            .font(.largeTitle)
            .navigationTitle("Tournament Detail")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ManageFieldView: View{
    var body: some View{
        Text("Manage Field View")
            .font(.largeTitle)
            .navigationTitle("Manage Field")
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct FieldsView: View{
//    var body: some View{
//        Text("Fields View")
//            .font(.largeTitle)
//            .navigationTitle("Fields")
//            .navigationBarTitleDisplayMode(.inline)
//    }
//}

struct TeamView: View{
    var body: some View{
        Text("Team View")
            .font(.largeTitle)
            .navigationTitle("Team")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ClubView: View{
    var body: some View{
        Text("Club View")
            .font(.largeTitle)
            .navigationTitle("Club")
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct GroupView: View{
//    var body: some View{
//        Text("Group View")
//            .font(.largeTitle)
//            .navigationTitle("Group")
//            .navigationBarTitleDisplayMode(.inline)
//    }
//}


