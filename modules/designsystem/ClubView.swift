// The Swift Programming Language
// https://docs.swift.org/swift-book
//import SwiftUI
//
//public struct GroupView: View {
//    public init () {
//
//    }
//
//    public var body: some View {
//        Text("You have no groups\nCreate some groups")
//            .multilineTextAlignment(.center).padding()
//    }
//}

// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import FirebaseFirestore

struct Club: Identifiable {
    var id: String // Firestore document ID
    let name: String
    let type: String
    let code: String
    var memberCount: Int
    
    func displayText() -> String {
        return "\(name) (\(code))"
    }
}

final class GroupStore: ObservableObject {
    @Published var groups: [Club] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "groups_1"
    
    init(){
        fetchGroups()
    }
    
    // Function to fetch groups from Firestore
    func fetchGroups() {
        db.collection(collectionName).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("❌ Error fetching groups: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.groups.removeAll() // Clear existing groups befor updating
                self.groups = documents.compactMap { doc -> Club? in
                    let data = doc.data()
                    return self.decodeGroup(id: doc.documentID, data: data)
                }
            }
        }
    }
    
     // Function to add a group to Firestore
    func addGroup(name: String, type: String) {
        let groupRef = db.collection(collectionName).document() // Generates unique Firestore ID
        let groupID = groupRef.documentID // Get the auto-generated ID
        let newGroup = Club(id: groupID, name: name, type: type, code: generateSixCharacterCode(), memberCount: 1)

        let groupData: [String: Any] = [
            "id": groupID,
            "name": newGroup.name,
            "type": newGroup.type,
            "code": newGroup.code,
            "memberCount": newGroup.memberCount
        ]

        groupRef.setData(groupData) { error in
            if let error = error {
                print("Error saving group to Firestore: \(error.localizedDescription)")
            } else {
                print("Group saved successfully: \(newGroup.name)")
            }
        }
    }
    
    // Function to join a group with a code
    func joinGroup(withCode code: String, completion: @escaping (Bool) -> Void) {
           let query = db.collection(collectionName).whereField("code", isEqualTo: code)
           
           query.getDocuments { snapshot, error in
               if let document = snapshot?.documents.first {
                   let data = document.data()
                   var memberCount = data["memberCount"] as? Int ?? 0
                   memberCount += 1
                   
                   document.reference.updateData(["memberCount": memberCount]) { error in
                       if let error = error {
                           print("Error updating group: \(error.localizedDescription)")
                           completion(false)
                       } else {
                           completion(true)
                       }
                   }
               } else {
                   print("Group not found for code: \(code)")
                   completion(false)
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

struct GroupView: View {
    @State private var showMenu = false
    @State private var navigateToCreate = false
    @State private var showJoinSheet = false
    @State private var showFeedback = false
    
    @StateObject var store = GroupStore()
    
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
                                MenuButton(icon: "plus", text: "Create") {
                                    navigateToCreate = true
                                    showMenu = false
                                }
                                MenuButton(icon: "qrcode", text: "Join with QR") {
                                    showMenu = false
                                }
                                MenuButton(icon: "chevron.left.slash.chevron.right", text: "Join with Code") {
                                    showJoinSheet = true
                                    showMenu = false
                                }
                                MenuButton(icon: "magnifyingglass", text: "Find") {
                                    showMenu = false
                                }
                            }
                            .padding(.trailing, 50)
                            .padding(.bottom, 100)
                        }
                    }
                    .transition(.opacity)
                }
                
                NavigationLink(
                    destination: CreateGroupView().environmentObject(store),
                    isActive: $navigateToCreate,
                    label: { EmptyView() }
                )
            }
            .sheet(isPresented: $showJoinSheet) {
                JoinWithCodeView()
                    .environmentObject(store)
                    .presentationDetents([.fraction(0.35)])
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

struct MenuButton: View {
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

struct CreateGroupView: View {
    @EnvironmentObject var store: GroupStore
    @Environment(\.dismiss) var dismiss
    
    @State private var groupName = ""
    @State private var groupType = "Club"
    @State private var showDropdown = false
    
    let groupTypes = ["Club", "Team", "Community", "Work"]
    
//    func generateSixCharacterCode() -> String {
//        let randomInt = Int.random(in: 0...999_999)
//        return String(format: "%06d", randomInt)
//    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New Club")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            
            TextField("Name", text: $groupName)
                .padding()
                .frame(height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Group Type")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Button(action: {
                    withAnimation { showDropdown.toggle() }
                }) {
                    HStack {
                        Text(groupType)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                
                if showDropdown {
                    VStack(spacing: 0) {
                        ForEach(groupTypes, id: \.self) { type in
                            Button(action: {
                                self.groupType = type
                                withAnimation { showDropdown = false }
                            }) {
                                Text(type)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.white)
                            }
                            .foregroundColor(.black)
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(Color.gray.opacity(0.5)),
                                alignment: .bottom
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
            }
            .zIndex(1)
            
            Button(action: {
                store.addGroup(name: groupName, type: groupType)
                dismiss()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(groupName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(groupName.isEmpty)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create Group")
    }
}

struct JoinWithCodeView: View {
    @EnvironmentObject var store: GroupStore
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
                store.joinGroup(withCode: joinCode) { success in
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

struct GroupRow: View {
    var group: Club
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                Text(group.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text("Members:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(group.memberCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text("Code: \(group.code)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct GroupsListView: View {
    @EnvironmentObject var store: GroupStore
    
    var body: some View {
        List {
            ForEach(store.groups) { group in
                GroupRow(group: group)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("My Groups")
        .navigationBarBackButtonHidden(true)
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateGroupView()
                .environmentObject(GroupStore())
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
    }
}

struct JoinWithCodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JoinWithCodeView()
                .environmentObject(GroupStore())
        }
    }
}


