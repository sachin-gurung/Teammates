// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct HomeView: View {
    
    public init() {}
    
    public var body: some View {
        Text("You have no activities\nJoin some teams, and tournaments")
                .multilineTextAlignment(.center).padding()
    }
}
