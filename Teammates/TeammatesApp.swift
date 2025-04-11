//
//  TeammatesApp.swift
//  Teammates
//
//  Created by Sachin Gurung on 7/30/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import StreamChat
import StreamChatUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TeammatesApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel();
    @StateObject var store = clubStore()
    @State private var showFeedback = false
    @StateObject var motionManager = MotionManager() // Add MotionManager
    
    init(){
        // Determine the correct configuration file
        let isDev = Bundle.main.bundleIdentifier?.contains("dev") ?? false
        let configFileName = isDev ? "GoogleService-Info-dev" : "GoogleService-Info-prod"

        // Load the configuration manually
        if let filePath = Bundle.main.path(forResource: configFileName, ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        } else{
            fatalError("Could not load \(configFileName).plist")
        }
    }
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(authViewModel)
                .environmentObject(store)
            
//            let isAuthenticated = authViewModel.authenticationState == .authenticated
//            let currentUserID = authViewModel.user?.uid ?? "test-user"
//            let currentUserName = authViewModel.user?.displayName ?? "Test User"
//            let testToken = Token.development(userId: currentUserID)
            
//            if isAuthenticated {
//                StreamManager.shared.connectUser(
//                    id: currentUserID,
//                    name: currentUserName,
//                    imageURL: nil,
//                    token: testToken.rawValue)
//            }
            
//            ZStack {
//                if isAuthenticated {
//                    ContentView()
//                        .environmentObject(authViewModel)
//                        .environmentObject(store) // Ensuring GroupStore is available globally
//                } else {
//                    LoginView(type: "guest", code: "NA")
//                        .environmentObject(authViewModel)
//                }
//            }
//            .onChange(of: motionManager.didShake) { newValue in
//                if newValue {
//                    showFeedback = true
//                    motionManager.didShake = false // Reset shake detection
//                }
//            }
//            .sheet(isPresented: $showFeedback) {
//                FeedbackView()
//            }
        }
    }
}

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var store: clubStore
    @State private var showFeedback = false
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        let isAuthenticated = authViewModel.authenticationState == .authenticated
        let currentUserID = authViewModel.user?.uid ?? "test-user"
        let currentUserName = authViewModel.user?.displayName ?? "Test User"
        let testToken = Token.development(userId: currentUserID)
        
        // Connect user to Stream only once on load
        DispatchQueue.main.async {
            if isAuthenticated {
                StreamManager.shared.connectUser(
                    id: currentUserID,
                    name: currentUserName,
                    imageURL: nil,
                    token: testToken.rawValue
                )
            }
        }
        return ZStack {
            if isAuthenticated {
                ContentView()
            } else {
                LoginView(type: "guest", code: "NA")
            }
        }
        .onChange(of: motionManager.didShake) { newValue in
            if newValue {
                showFeedback = true
                motionManager.didShake = false
            }
        }
        .sheet(isPresented: $showFeedback){
            FeedbackView()
        }
    }
}

