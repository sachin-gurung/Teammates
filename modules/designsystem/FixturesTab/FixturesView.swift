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
    @State private var isTournamentSettingsActive = false
    // Added for Start Date picker
    @State private var showStartDatePicker = false
    @State private var startDate: Date? = nil
    // Added for Start Time picker
    @State private var showStartTimePicker = false
    @State private var startTime: Date? = nil
    // Added for End Date picker
    @State private var showEndDatePicker = false
    @State private var endDate: Date? = nil
    // Added for End Time picker
    @State private var showEndTimePicker = false
    @State private var endTime: Date? = nil
    // State for End Date error alert
    @State private var showEndDateErrorAlert = false
    // State for End Time error alert
    @State private var showEndTimeErrorAlert = false
    // Entry Fee state
    @State private var entryFee: String = "Free"
    @State private var showEntryFeeAlert = false
    @State private var entryFeeInput = ""
    // Currency state for entry fee
    @State private var selectedCurrencyCode = Locale.current.currencyCode ?? "USD"
    let supportedCurrencies = ["USD"]

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

            // Tournament logo just below the segmented tab and above the team name (only in tab 2, and not in Notification Settings or Tournament Settings subview)
            if selectedTab == 2 && !isNotificationTabActive && !isTournamentSettingsActive {
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
                    } else if isTournamentSettingsActive {
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Text("\(teamName) Settings")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))

                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(["Start Date", "Start Time", "End Date", "End Time", "Entry fee", "Format", "Status", "Visibility", "Rules", "Users"], id: \.self) { item in
                                    if item == "Start Date" {
                                        Button(action: {
                                            showStartDatePicker = true
                                        }) {
                                            HStack {
                                                Text("Start Date")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(startDate != nil ? formattedDate(startDate!) : "Not Set")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal)
                                        }
                                    } else if item == "Start Time" {
                                        Button(action: {
                                            showStartTimePicker = true
                                        }) {
                                            HStack {
                                                Text("Start Time")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(startTime != nil ? formattedTime(startTime!) : "Not Set")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal)
                                        }
                                    } else if item == "End Date" {
                                        Button(action: {
                                            showEndDatePicker = true
                                        }) {
                                            HStack {
                                                Text("End Date")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(endDate != nil ? formattedDate(endDate!) : "Not Set")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal)
                                        }
                                    } else if item == "End Time" {
                                        Button(action: {
                                            showEndTimePicker = true
                                        }) {
                                            HStack {
                                                Text("End Time")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(endTime != nil ? formattedTime(endTime!) : "Not Set")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal)
                                        }
                                    } else if item == "Entry fee" {
                                        Button(action: {
                                            entryFeeInput = entryFee == "Free" ? "" : entryFee
                                            showEntryFeeAlert = true
                                        }) {
                                            HStack {
                                                Text("Entry fee")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(entryFee)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal)
                                        }
                                    } else {
                                        HStack {
                                            Text(item)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("Not Set")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.top)
                            // Start Date Picker Sheet (replaced with alert below)
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
                                            if item.0 == "Tournament Settings" {
                                                isTournamentSettingsActive = true
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
        .alert("Change Tournament Fee", isPresented: $showEntryFeeAlert, actions: {
            TextField("Enter amount or leave empty for Free", text: $entryFeeInput)
                .keyboardType(.numbersAndPunctuation)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                let trimmed = entryFeeInput.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    entryFee = "Free"
                } else if let amount = Double(trimmed.filter("0123456789.".contains)) {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.currencyCode = selectedCurrencyCode
                    entryFee = formatter.string(from: NSNumber(value: amount)) ?? "$\(trimmed)"
                } else {
                    // Keep the existing value if input is invalid
                    entryFee = entryFee
                }

                // Firestore update
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
                            "entry_fee": entryFee
                        ]) { error in
                            if let error = error {
                                print("Error updating entry fee: \(error)")
                            } else {
                                print("Entry fee updated successfully")
                            }
                        }
                    }
            }
        })
        .sheet(isPresented: $showStartDatePicker) {
            VStack(spacing: 20) {
                Text("Select Start Date")
                    .font(.headline)
                    .padding(.top)

                DatePicker("",
                           selection: Binding(
                               get: { startDate ?? Date() },
                               set: { startDate = $0 }
                           ),
                           displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                Button("Done") {
                    showStartDatePicker = false
                    if let selectedDate = startDate {
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
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let formattedDate = formatter.string(from: selectedDate)

                                db.collection("tournaments_1").document(document.documentID).updateData([
                                    "start_date": formattedDate
                                ]) { error in
                                    if let error = error {
                                        print("Error updating start date: \(error)")
                                    } else {
                                        print("Start date updated successfully")
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showStartTimePicker) {
            VStack(spacing: 20) {
                Text("Select Start Time")
                    .font(.headline)
                    .padding(.top)

                DatePicker("",
                           selection: Binding(
                               get: { startTime ?? Date() },
                               set: { startTime = $0 }
                           ),
                           displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                Button("Done") {
                    showStartTimePicker = false
                    if let selectedTime = startTime {
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
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm"
                                let formattedTime = formatter.string(from: selectedTime)

                                db.collection("tournaments_1").document(document.documentID).updateData([
                                    "start_time": formattedTime
                                ]) { error in
                                    if let error = error {
                                        print("Error updating start time: \(error)")
                                    } else {
                                        print("Start time updated successfully")
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEndDatePicker) {
            VStack(spacing: 20) {
                Text("Select End Date")
                    .font(.headline)
                    .padding(.top)

                DatePicker("",
                           selection: Binding(
                               get: { endDate ?? Date() },
                               set: {
                                   if let start = startDate, $0 < start {
                                       showEndDateErrorAlert = true
                                       endDate = nil
                                   } else {
                                       endDate = $0
                                   }
                               }
                           ),
                           displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                Button("Done") {
                    showEndDatePicker = false
                    if let selectedDate = endDate {
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
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let formattedDate = formatter.string(from: selectedDate)

                                db.collection("tournaments_1").document(document.documentID).updateData([
                                    "end_date": formattedDate
                                ]) { error in
                                    if let error = error {
                                        print("Error updating end date: \(error)")
                                    } else {
                                        print("End date updated successfully")
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
        .alert("Invalid End Date", isPresented: $showEndDateErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("End Date cannot be earlier than the Start Date.")
        }
        .sheet(isPresented: $showEndTimePicker) {
            VStack(spacing: 20) {
                Text("Select End Time")
                    .font(.headline)
                    .padding(.top)

                DatePicker("",
                           selection: Binding(
                               get: { endTime ?? Date() },
                               set: {
                                   if let start = startDate,
                                      let sTime = startTime,
                                      let eDate = endDate,
                                      Calendar.current.isDate(eDate, inSameDayAs: start),
                                      $0 <= sTime {
                                       showEndTimeErrorAlert = true
                                       endTime = nil
                                   } else {
                                       endTime = $0
                                   }
                               }),
                           displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                Button("Done") {
                    showEndTimePicker = false
                    if let selectedTime = endTime {
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
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm"
                                let formattedTime = formatter.string(from: selectedTime)

                                db.collection("tournaments_1").document(document.documentID).updateData([
                                    "end_time": formattedTime
                                ]) { error in
                                    if let error = error {
                                        print("Error updating end time: \(error)")
                                    } else {
                                        print("End time updated successfully")
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
        .alert("Invalid End Time", isPresented: $showEndTimeErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("End Time cannot be earlier than or equal to the Start Time when End Date is the same as Start Date.")
        }
    }

    // Helper for formatting date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Helper for formatting time
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
