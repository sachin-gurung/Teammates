// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Firebase

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
    @State private var tournaments: [Tournament] = []
    @State private var showMenu = false
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var tournamentName: String = ""
    @State private var selectedFormat: String = "League"
    @State private var showDuplicateAlert = false
    
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
        .onAppear {
            loadTournaments()
        }
        .overlay(
            showCreateSheet ? TournamentDialog(
                name: $tournamentName,
                format: $selectedFormat,
                onDismiss: {
                    tournamentName = ""
                    showCreateSheet = false
                },
                onConfirm: {
                    let trimmedName = tournamentName.trimmingCharacters(in: .whitespacesAndNewlines)
                    let db = Firestore.firestore()
                    db.collection("tournaments_1")
                        .whereField("name_lower", isEqualTo: trimmedName.lowercased())
                        .getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("Error checking for duplicates: \(error)")
                                return
                            }
                            if let documents = querySnapshot?.documents, !documents.isEmpty {
                                showDuplicateAlert = true
                            } else {
                                let newTournament = Tournament(name: trimmedName, league: selectedFormat, teams: 0)
                                tournaments.append(newTournament)

                                db.collection("tournaments_1").addDocument(data: [
                                    "name": newTournament.name,
                                    "name_lower": newTournament.name.lowercased(),
                                    "league": newTournament.league,
                                    "teams": newTournament.teams
                                ])
                                tournamentName = ""
                                showCreateSheet = false
                            }
                        }
                }
            ) : nil
        )
        .sheet(isPresented: $showJoinSheet) {
            Text("Join with Code")
                .presentationDetents([.fraction(0.35)])
                .presentationDragIndicator(.visible)
        }
        .alert("Tournament already exists", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {
                tournamentName = ""
            }
        }
    }

    // Loads tournaments from Firestore and populates the tournaments array
    private func loadTournaments() {
        let db = Firestore.firestore()
        db.collection("tournaments_1").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching tournaments: \(error)")
                return
            }
            if let documents = snapshot?.documents {
                tournaments = documents.map { doc in
                    let data = doc.data()
                    return Tournament(
                        name: data["name"] as? String ?? "Unknown",
                        league: data["league"] as? String ?? "Unknown",
                        teams: data["teams"] as? Int ?? 0
                    )
                }
            }
        }
    }
}

struct TournamentDialog: View {
    @Binding var name: String
    @Binding var format: String
    var onDismiss: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Name your tournament")
                    .font(.headline)

                TextField("Enter tournament name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Format")
                    .font(.headline)

                Picker("Format", selection: $format) {
                    Text("League").tag("League")
                    Text("Knockout").tag("Knockout")
                    Text("League and Knockout").tag("League and Knockout")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                HStack {
                    Spacer()
                    Button("Dismiss", action: onDismiss)
                        .foregroundColor(.purple)

                    Button("Confirm", action: onConfirm)
                        .foregroundColor(name.isEmpty ? .gray : .purple)
                        .disabled(name.isEmpty)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 40)
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
