//
//  DiscoverView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel = CommunitiesViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.communities) { community in
                NavigationLink(destination: CommunityView(community: community)) {
                    HStack(alignment: .center) {
                        AsyncImage(url: URL(string: community.communityImageURL)!,
                                   placeholder: { ProgressView() },
                                   image: { Image(uiImage: $0).resizable() })
                            .frame(width: 100, height: 100, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                        Text(community.communityName)
                            .font(.headline)
                    }
                }
            }
            .navigationBarTitle("Discover")
            .onAppear() {
                self.viewModel.getCommunities()
            }
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
