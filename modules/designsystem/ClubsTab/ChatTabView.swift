//
//  ChatTabView.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/10/25.
//

import SwiftUI
import StreamChat
import StreamChatUI

struct ChatTabView: View {
    var club: Club
    
    var body: some View {
        ChatChannelView(channelId: .init(type: .messaging, id: club.id))
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct ChatChannelView: UIViewControllerRepresentable {
    let channelId: ChannelId
    
    func makeUIViewController(context: Context) -> ChatChannelVC {
        let client = StreamManager.shared.chatClient
        let controller = client.channelController(for: channelId)
        let channelVC = ChatChannelVC()
        channelVC.channelController = controller
        return channelVC
    }
    
    func updateUIViewController(_ uiViewController: ChatChannelVC, context: Context) {
        
    }
}
