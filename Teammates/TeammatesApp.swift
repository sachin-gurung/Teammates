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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TeammatesApp: App {
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
    
//    // register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
