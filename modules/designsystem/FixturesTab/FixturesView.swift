// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Firebase
import StreamChat
import StreamChatUI

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
                        NavigationLink(destination: TournamentTeamDetailView(teamName: tournament.name)) {
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
            JoinTournamentView()
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


struct JoinTournamentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var digit1 = ""
    @State private var digit2 = ""
    @State private var digit3 = ""
    @State private var digit4 = ""
    @State private var digit5 = ""
    @State private var digit6 = ""
    @FocusState private var focusedField: Int?

    @State private var showError = false
    @State private var errorMessage = ""

    var code: String {
        return "\(digit1)\(digit2)\(digit3)\(digit4)\(digit5)\(digit6)".uppercased()
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Join With Code")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(0..<6) { index in
                    codeBox(for: index)
                }
            }
            .padding(.horizontal)

            Button(action: {
                let db = Firestore.firestore()
                db.collection("tournaments_1")
                    .whereField("code", isEqualTo: code)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            errorMessage = "Error: \(error.localizedDescription)"
                            showError = true
                            return
                        }

                        guard snapshot?.documents.first != nil else {
                            errorMessage = "Tournament not found for code \(code)"
                            showError = true
                            return
                        }

                        dismiss()
                    }
            }) {
                Text("Join")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .disabled(code.count < 6)
            .padding(.horizontal)

        }
        .onAppear {
            focusedField = 0
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    @ViewBuilder
    private func codeBox(for index: Int) -> some View {
        let binding: Binding<String> = {
            switch index {
            case 0: return $digit1
            case 1: return $digit2
            case 2: return $digit3
            case 3: return $digit4
            case 4: return $digit5
            case 5: return $digit6
            default: return .constant("")
            }
        }()
        if index >= 0 && index < 6 {
            TextField("", text: binding)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: index)
                .frame(width: 40, height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .onChange(of: binding.wrappedValue) { newValue in
                    if newValue.count > 1 {
                        binding.wrappedValue = String(newValue.prefix(1))
                    }
                    if !newValue.isEmpty {
                        if index < 5 {
                            focusedField = index + 1
                        } else {
                            focusedField = nil
                        }
                    }
                }
        } else {
            EmptyView()
        }
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

// MARK: - TournamentTeamDetailView (Tabbed)
struct TournamentTeamDetailView: View {
    @State var teamName: String
    @State private var selectedTab: Int = 0
    @State private var isEditingName = false
    @State private var newTournamentName = ""
    @State private var showNameChangeAlert = false
    @State private var isNotificationTabActive = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Chat").tag(0)
                Text("Matches & Results").tag(1)
                Image(systemName: "gearshape").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Divider()

            // Tournament logo just below the segmented tab and above the team name (only in tab 2, and not in Notification Settings subview)
            if selectedTab == 2 && !isNotificationTabActive {
                Image("tournaments")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.top, 10)
            }

            Group {
                if selectedTab == 0 {
                    ChatChannelView(channelId: .init(type: .messaging, id: teamName))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                } else if selectedTab == 1 {
                    VStack {
                        Text("Matches & Results for \(teamName)")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                } else {
                    if isNotificationTabActive {
                        VStack(alignment: .leading) {
                            HStack {
                                Button(action: {
                                    isNotificationTabActive = false
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                }
                                Text("Notification Settings")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.leading, 8)
                            }
                            .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.ignoresSafeArea())
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                Button(action: {
                                    newTournamentName = teamName
                                    isEditingName = true
                                }) {
                                    Text(teamName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                }

                                Divider()

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    ForEach([
                                        ("Tournament Settings", "gear"),
                                        ("Teams & Fixtures", "person.3"),
                                        ("Notification Settings", "bell"),
                                        ("Leave", "xmark.circle.fill")
                                    ], id: \.0) { item in
                                        Button(action: {
                                            if item.0 == "Notification Settings" {
                                                isNotificationTabActive = true
                                            }
                                            // Add action here for other buttons if needed
                                        }) {
                                            Text(item.0)
                                                .foregroundColor(item.0 == "Leave" ? .white : .black)
                                                .frame(width: 150, height: 70)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal)
                                                .background(item.0 == "Leave" ? Color(red: 152/255, green: 67/255, blue: 56/255) : Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                        }
                        .background(Color(red: 0.93, green: 0.89, blue: 1.0).ignoresSafeArea())
                    }
                }
            }
        }
        .alert("Edit Tournament Name", isPresented: $isEditingName, actions: {
            TextField("New tournament name", text: $newTournamentName)
            Button("Cancel", role: .cancel) {
                isEditingName = false
            }
            Button("Confirm") {
                let trimmedName = newTournamentName.trimmingCharacters(in: .whitespaces)
                guard !trimmedName.isEmpty else { return }
                let db = Firestore.firestore()
                db.collection("tournaments_1")
                    .whereField("name", isEqualTo: teamName)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching document: \(error)")
                            return
                        }
                        guard let document = snapshot?.documents.first else {
                            print("Tournament not found")
                            return
                        }
                        db.collection("tournaments_1").document(document.documentID).updateData([
                            "name": trimmedName,
                            "name_lower": trimmedName.lowercased()
                        ]) { error in
                            if let error = error {
                                print("Error updating name: \(error)")
                            } else {
                                teamName = trimmedName
                                showNameChangeAlert = true
                            }
                        }
                    }
                isEditingName = false
            }
        }, message: {
            Text("Enter a new name for the tournament.")
        })
        .alert("Tournament name updated to '\(newTournamentName)'", isPresented: $showNameChangeAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct NotificationsView: View {
    var body: some View {
        VStack {
            Text("Notifications Settings")
                .foregroundColor(.white)
                .font(.title)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
