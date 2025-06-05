// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct FixturesView: View {
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var showMenu = false
    
    public init () {
        
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: TournamentPageView()) {
                    ZStack(alignment: .bottom) {
                        Image("tournaments")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(16)

                        Text("Tournaments")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }

                NavigationLink(destination: MatchView()) {
                    ZStack(alignment: .bottom) {
                        Image("matches")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(16)

                        Text("Matches")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal)
                }
                Spacer()
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

public struct TournamentPageView: View{
    @State private var tournaments: [Tournament] = [Tournament(name: "Tournament 1", league: "League 1", teams: 1), Tournament(name: "Tournament 2", league: "League 2", teams: 2), Tournament(name: "Tournament 3", league: "League 3", teams: 3)]
    @State private var showMenu = false
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    
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
            
            // Floating menu buttons
            if showMenu {
                VStack(spacing: 16) {
                    Spacer()
                    FixtureMenuButton(icon: "plus", text: "New Tournament") {
                        showCreateSheet = true
                        showMenu = false
                    }
                    FixtureMenuButton(icon: "chevron.left.slash.chevron.right", text: "Register with Code") {
                        showJoinSheet = true
                        showMenu = false
                    }
                    FixtureMenuButton(icon: "magnifyingglass", text: "Find") {
                        showMenu = false
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
                .padding(.bottom, 80)
                .transition(.opacity)
            }
            
            // Floating "+" button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation { showMenu.toggle() }
                    }) {
                        Image(systemName: showMenu ? "xmark" : "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(16)
                    }
                    .background(Color(red: 90/255, green: 103/255, blue: 165/255))
                    .clipShape(Circle())
                    .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                    .padding(.trailing, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            Text("Create Tournament Sheet")
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showJoinSheet) {
            Text("Join with Code")
                .presentationDetents([.fraction(0.35)])
                .presentationDragIndicator(.visible)
        }
    }
}
// MARK: - MenuButton Component
struct FixtureMenuButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(Color(red: 90/255, green: 103/255, blue: 165/255))
            .cornerRadius(28)
            .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
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

struct FixturesView_Previews: PreviewProvider {
    static var previews: some View {
        FixturesView()
    }
}



// MARK: - Corner Radius for Specific Corners Modifier
import UIKit

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
