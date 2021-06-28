//
//  NewPostView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/8/21.
//

import SwiftUI

struct NewPostView: View {
    @ObservedObject var viewModel = CommunitiesViewModel()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Text("Choose a community")
                        .font(.title)
                    
                    Spacer()
                    
                }
                .padding()
                .padding(.bottom)
                
                SearchBar(text: $searchText)
                    .padding(.top, -30)
                
                List(viewModel.communities.filter({ searchText.isEmpty ? true : $0.communityName.contains(searchText) })) { community in
                    NavigationLink(destination: CommunityNewPostView(community: community)) {
                        Text(community.communityName)
                    }
                }
                
            }
            .onAppear {
                self.viewModel.getCommunities()
            }
            
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
