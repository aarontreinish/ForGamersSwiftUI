//
//  TabBarView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle.fill")
                    Text("Discover")
                }
            
            CreateView()
                .tabItem {
                    Image(systemName: "plus.square.fill")
                    Text("Create")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Account")
                }
        }
        .accentColor(.red)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
