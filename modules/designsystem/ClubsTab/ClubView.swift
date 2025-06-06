import SwiftUI
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct Club: Identifiable {
    var id: String // Firestore document ID
    let name: String
    let type: String
    let code: String
    var memberCount: Int
    var logoImage: UIImage? = nil
    
    func displayText() -> String {
        return "\(name) (\(code))"
    }
}

final class clubStore: ObservableObject {
    @Published var groups: [Club] = []
    @Published var selectedClub: Club? = nil
    
    private let db = Firestore.firestore()
    private let collectionName = "clubs_1"
    
    init(){
        fetchClubs()
    }
    
    // Function to fetch groups from Firestore
    func fetchClubs() {
        db.collection(collectionName).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching clubs: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.groups.removeAll()
                self.groups = documents.compactMap { doc -> Club? in
                    let data = doc.data()
                    return self.decodeGroup(id: doc.documentID, data: data)
                }
            }
        }
    }
    
     // Function to add a group to Firestore
    func addClub(name: String, type: String, completion: @escaping (Bool) -> Void) {
        let clubRef = db.collection(collectionName).document() // Generates unique Firestore ID
        let clubID = clubRef.documentID // Get the auto-generated ID
        let newClub = Club(id: clubID, name: name, type: type, code: generateSixCharacterCode(), memberCount: 1)

        let clubData: [String: Any] = [
            "id": clubID,
            "name": newClub.name,
            "type": newClub.type,
            "code": newClub.code,
            "memberCount": newClub.memberCount
        ]

        clubRef.setData(clubData) { error in
            if let error = error {
                print("Error saving group to Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Group saved successfully: \(newClub.name)")
                completion(true)
            }
        }
    }
    
    // Function to join a group with a code
    func joinClub(withCode code: String, completion: @escaping (Bool) -> Void) {
           let query = db.collection(collectionName).whereField("code", isEqualTo: code)
           
        query.getDocuments { snapshot, error in
            if let document = snapshot?.documents.first {
                let data = document.data()
                var memberCount = data["memberCount"] as? Int ?? 0
                memberCount += 1
                
                document.reference.updateData(["memberCount": memberCount]) { error in
                    completion(error == nil)
                }
            } else {
                    print("Group not found for code: \(code)")
                    completion(true)
                }
           }
       }
    
    // Function to generate a 6-digit random code
    func generateSixCharacterCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    // Function to manually decode Firestore data into a Group object
        private func decodeGroup(id: String, data: [String: Any]) -> Club? {
            guard let firestoreId = data["id"] as? String,
                  let name = data["name"] as? String,
                  let type = data["type"] as? String,
                  let code = data["code"] as? String,
                  let memberCount = data["memberCount"] as? Int else {
                return nil
            }
            
            return Club(id: firestoreId, name: name, type: type, code: code, memberCount: memberCount)
        }
}

struct GroupRow: View {
    var group: Club
    static let context = CIContext()
    static let filter = CIFilter.qrCodeGenerator()

    private func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        Self.filter.setValue(data, forKey: "inputMessage")

        if let outputImage = Self.filter.outputImage,
           let cgimg = Self.context.createCGImage(outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)), from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        return nil
    }

    private func shareClubAsQRCode(_ club: Club) {
        guard let url = URL(string: "https://snsnextgenservices.com/club/\(club.id)"),
              let qrImage = generateQRCode(from: url.absoluteString) else { return }

        let activityVC = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    var body: some View {
        HStack {
            // Logo
            if let image = group.logoImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(Text("🏆"))
            }

            // Name and info
            VStack(alignment: .leading) {
                Text(group.name)
                    .font(.headline)
                Text("Members: \(group.memberCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Code: \(group.code)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // QR Button
            Button(action: {
                shareClubAsQRCode(group)
            }) {
                Image(systemName: "qrcode")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct clubView: View {
    @State private var showMenu = false
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var showFeedback = false
    
    @StateObject private var store = clubStore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if store.groups.isEmpty && !showMenu {
                    Text("You have no clubs\nCreate some clubs")
                        .multilineTextAlignment(.center)
                        .padding()
                        .transition(.opacity)
                } else if !store.groups.isEmpty {
                    GroupsListView()
                        .environmentObject(store)
                }
                
                if showMenu {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            CurvedBackground()
                                .fill(Color(red: 230/255, green: 236/255, blue: 250/255))
                                .frame(width: UIScreen.main.bounds.width, height: 500)
                                .transition(.move(edge: .trailing))
                                .animation(.easeInOut(duration: 0.3), value: showMenu)
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                
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
                
                if showMenu {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 16) {
                                ClubMenuButton(icon: "plus", text: "Create") {
                                    showCreateSheet = true
                                    showMenu = false
                                }
                                ClubMenuButton(icon: "qrcode", text: "Join with QR") {
                                    showMenu = false
                                }
                                ClubMenuButton(icon: "chevron.left.slash.chevron.right", text: "Join with Code") {
                                    showJoinSheet = true
                                    showMenu = false
                                }
                                FixtureMenuButton(icon: "magnifyingglass", text: "Find") {
                                    showMenu = false
                                }
                            }
                            .padding(.trailing, 50)
                            .padding(.bottom, 100)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .sheet(isPresented: $showJoinSheet) {
                JoinWithCodeView()
                    .environmentObject(store)
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCreateSheet) {
                createClubSheet()
                    .environmentObject(store)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct CurvedBackground: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addQuadCurve(
                to: CGPoint(x: width, y: 0),
                control: CGPoint(x: width / 2, y: height - 200)
            )
        }
    }
}

struct ClubMenuButton: View {
    var icon: String
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color(red: 36/255, green: 50/255, blue: 120/255)))
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct createClubSheet: View {
    @EnvironmentObject var store: clubStore
    @Environment(\.dismiss) var dismiss
    
    @State private var clubName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New Club")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            
            TextField("Club Name", text: $clubName)
                .padding()
                .frame(height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            Button(action: {
                store.addClub(name: clubName, type: "Club") { success in
                    if success {
                        dismiss()
                    } else {
                        print("Failed to create club")
                    }
                }
            }) {
                Text("Create")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(clubName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(clubName.isEmpty)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}

struct JoinWithCodeView: View {
    @EnvironmentObject var store: clubStore
    @Environment(\.dismiss) var dismiss
    
    @State private var digit1: String = ""
    @State private var digit2: String = ""
    @State private var digit3: String = ""
    @State private var digit4: String = ""
    @State private var digit5: String = ""
    @State private var digit6: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var focusedField: Int?
    
    var joinCode: String {
        return digit1 + digit2 + digit3 + digit4 + digit5 + digit6
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Join with Code")
                .font(.title)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            HStack(spacing: 8) {
                CodeDigitTextField(text: $digit1, tag: 1, focusedField: $focusedField)
                CodeDigitTextField(text: $digit2, tag: 2, focusedField: $focusedField)
                CodeDigitTextField(text: $digit3, tag: 3, focusedField: $focusedField)
                CodeDigitTextField(text: $digit4, tag: 4, focusedField: $focusedField)
                CodeDigitTextField(text: $digit5, tag: 5, focusedField: $focusedField)
                CodeDigitTextField(text: $digit6, tag: 6, focusedField: $focusedField)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Button(action: {
                store.joinClub(withCode: joinCode) { success in
                    if success {
                        dismiss()
                    } else {
                        alertMessage = "Group not found for code \(joinCode)."
                        showAlert = true
                    }
                }
            }) {
                Text("Join")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .onAppear { focusedField = 1 }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct CodeDigitTextField: View {
    @Binding var text: String
    var tag: Int
    @FocusState.Binding var focusedField: Int?
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 32, weight: .bold))
            .frame(width: 45, height: 55)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
                if !newValue.isEmpty {
                    focusedField = tag + 1
                }
            }
            .focused($focusedField, equals: tag)
    }
}

private func shareClub(_ club:Club){
    guard let url = URL(string: "https://snsnextgenservices.com/club/\(club.id)") else {return}
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = scene.windows.first?.rootViewController{
        rootVC.present(activityVC, animated: true)
    }
}

struct GroupsListView: View {
    @EnvironmentObject var store: clubStore
    
    var body: some View {
        List {
            ForEach(store.groups) { group in
                NavigationLink(destination: ClubDetailTabsView(club: group)) {
                    GroupRow(group: group)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("My Clubs")
        .navigationBarBackButtonHidden(true)
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            createClubSheet()
                .environmentObject(clubStore())
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        clubView()
    }
}

struct JoinWithCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JoinWithCodeView()
                .environmentObject(clubStore())
        }
    }
}


