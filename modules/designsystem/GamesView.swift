// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct GamesView: View {
    public init () {
        
    }
    
    public var body: some View {
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

public struct MatchView: View{
    public var body: some View{
        Text("Match View")
            .font(.largeTitle)
            .navigationTitle("Match")
            .navigationBarTitleDisplayMode(.inline)
    }
}

public struct ManageFieldView: View{
    public var body: some View{
        Text("Manage Field View")
            .font(.largeTitle)
            .navigationTitle("Manage Field")
            .navigationBarTitleDisplayMode(.inline)
    }
}

public struct ToolButton: View {
    var title: String
    
    public var body: some View{
        Text(title)
            .frame(width: 150, height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

public struct TeamView: View{
    public var body: some View{
        Text("Team View")
            .font(.largeTitle)
            .navigationTitle("Team")
            .navigationBarTitleDisplayMode(.inline)
    }
}

public struct ClubView: View{
    public var body: some View{
        Text("Club View")
            .font(.largeTitle)
            .navigationTitle("Club")
            .navigationBarTitleDisplayMode(.inline)
    }
}

public struct TournamentPageView: View{
    @State private var tournaments: [Tournament] = [Tournament(name: "Tournament 1", league: "League 1", teams: 1), Tournament(name: "Tournament 2", league: "League 2", teams: 2), Tournament(name: "Tournament 3", league: "League 3", teams: 3)]
    
    public var body: some View{
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

public struct FloatingAddButton: View {
    var action: () -> Void
    
    public var body: some View {
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

public struct TournamentDetailView: View{
    var Tournament: Tournament
    public var body: some View{
        Text("Tournament Detail View")
            .font(.largeTitle)
            .navigationTitle("Tournament Detail")
            .navigationBarTitleDisplayMode(.inline)
    }
}

public struct Tournament: Identifiable {
    public var id = UUID()
    public var name: String
    public var league: String
    public var teams: Int
}
