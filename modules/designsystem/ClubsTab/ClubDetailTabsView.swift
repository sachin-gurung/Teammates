import SwiftUI

struct ClubDetailTabsView: View {
    var club: Club
    @State private var selectedTab: ClubTopTabsView.Tab = .chat
    
    var body: some View {
        VStack(spacing: 0) {
            ClubTopTabsView(selectedTab: $selectedTab)
            
            Divider()
            
            Group {
                switch selectedTab {
                case .chat:
                    ChatTabView(club: club)
                case .events:
                    EventsTabView(club: club)
                case .settings:
                    SettingsTabView(club: club)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(club.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ClubDetailTabsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClubDetailTabsView(club: Club(
                id: "1", name: "EW", type: "Club", code: "ABC123", memberCount: 10)
            )
        }
    }
}
