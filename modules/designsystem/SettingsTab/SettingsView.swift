// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    public var body: some View {
        NavigationView{
            VStack{
                Text ("Settings View")
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}
