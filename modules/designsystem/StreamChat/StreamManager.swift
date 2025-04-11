//
//  StreamManager.swift
//  Teammates
//
//  Created by Sachin Gurung on 4/11/25.
//

import Foundation
import StreamChat

final class StreamManager {
    static let shared = StreamManager()
    
    let chatClient: ChatClient
    
    private init() {
        let config = ChatClientConfig(apiKey: .init("Your API Key")) // Replace this!
        chatClient = ChatClient(config: config)
    }
    
    func connectUser(id: String, name: String, imageURL: URL?, token: String){
        chatClient.connectUser(
            userInfo: .init(id: id, name: name, imageURL: imageURL),
            token: .init(stringLiteral: token)
        ) { error in
            if let error = error {
                print("Failed to connect user: \(error.localizedDescription)")
            } else {
                print("Stream user connected: \(name)")
            }
        }
    }
}
