//
//  ContentView.swift
//  Teammates
//
//  Created by Sachin Gurung on 7/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Spacer()
        
       // Bottom navigation bar
        HStack{
            VStack{
                Button(action: {
                    //TODO: Action
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .padding()
                }
                Text("Home")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    //TODO: Action
                }) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 24))
                        .padding()
                }
                Text("Tools")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    //TODO: Action
                }) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 24))
                        .padding()
                }
                Text("Messages")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            VStack{
                Button(action: {
                    //TODO: Action
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .padding()
                }
                Text("Settings")
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    ContentView()
}
