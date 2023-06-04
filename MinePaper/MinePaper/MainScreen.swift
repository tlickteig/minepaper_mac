//
//  ContentView.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/4/23.
//

import SwiftUI

struct MainScreen: View {
    var body: some View {
        
        TabView() {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("First Tab!")
                    Spacer()
                }
                Spacer()
            }
            .background(Color.blue)
            .tabItem {
                VStack {
                    Text("Desktop")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
