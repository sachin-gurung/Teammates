import SwiftUI

struct ClubTopTabsView: View {
    enum Tab {
        case chat, events, settings
    }
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                tabButton(label: "Chat", icon: nil, tab: .chat)
                tabButton(label: "Events", icon: nil, tab: .events)
            }
            
            Spacer()
            
            tabButton(label: nil, icon: "gearshape", tab: .settings)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }
    
    private func tabButton(label: String?, icon: String?, tab: Tab) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                if let label = label {
                    Text(label)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selectedTab == tab ? Color.white : Color.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: selectedTab == tab ? Color.black.opacity(0.1) : .clear, radius: 3, x: 0, y: 2)
        }
        .foregroundColor(.primary)
    }
}

struct ClubTopTabsView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedTab: ClubTopTabsView.Tab = .chat
        
        var body: some View {
            VStack(spacing: 0) {
                ClubTopTabsView(selectedTab: $selectedTab)
                Spacer()
                Text("Selected Tab: \(String(describing: selectedTab))")
                    .padding()
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
