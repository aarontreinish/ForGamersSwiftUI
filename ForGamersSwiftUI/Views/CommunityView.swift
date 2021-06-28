//
//  CommunityView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/3/21.
//

import SwiftUI

struct CommunityView: View {
    @ObservedObject var viewModel = PostsViewModel()
    @State var userIsJoined = false
    let community: Community
    @State private var isPresented = false
    @State var joinLeaveCommunityText = ""
    @State var userJoinedommunities: [String] = []
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.posts) { post in
                    HomeCellView(post: post)
                        .padding(.bottom)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .frame(width: UIScreen.main.bounds.width)
        .navigationTitle(community.communityName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(self.joinLeaveCommunityText) {
                    joinCommunity()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Post") {
                    postButtonAction()
                    self.isPresented.toggle()
                }.sheet(isPresented: $isPresented, content: {
                    CommunityNewPostView(community: community)
                })
            }
        }
        .onAppear {
            viewModel.getPostsForCommunity(communityName: community.communityName)
            
            FirestoreManager.shared.getUserJoinedCommunities { (communities) in
                if let communities = communities {
                    userJoinedommunities = communities
                    if communities.contains(community.communityName) {
                        userIsJoined = true
                        joinLeaveCommunityText = "Leave Community"
                    } else {
                        userIsJoined = false
                        joinLeaveCommunityText = "Join Community"
                    }
                }
            }
        }
    }
    
    func postButtonAction() {
        print("Post tapped")
        print(viewModel.posts)
        
    }
    
    func joinCommunity() {
        if userIsJoined == true {
            print(userJoinedommunities)
            FirestoreManager.shared.leaveCommunity(communityName: community.communityName) { (didSucceed) in
                print(userJoinedommunities)
                if didSucceed {
                    userIsJoined = false
                    joinLeaveCommunityText = "Join Community"
                    DatabaseManager.shared.updateUserForLeaving(communityName: community.communityName) { (didLeave) in
                        if didLeave == true {
                            print(didLeave)
                        } else {
                            print("did not join")
                        }
                    }
                } else {
                    print("Error joining/leaving community")
                }
            }
        } else {
            print(userJoinedommunities)
            FirestoreManager.shared.joinCommunity(communityName: community.communityName) { (didSucceed) in
                if didSucceed {
                    print(userJoinedommunities)
                    userIsJoined = true
                    joinLeaveCommunityText = "Leave Community"
                    DatabaseManager.shared.updateUserForJoining(communityName: community.communityName) { (didJoin) in
                        if didJoin == true {
                            print(didJoin)
                        } else {
                            print("did not join")
                        }
                    }
                } else {
                    print("Error joining/leaving community")
                }
            }
        }
    }
    
//    func joinCommunity() {
//        print("Join tapped")
//        if userIsJoined == true {
//            FirestoreManager.shared.leaveCommunity(communityName: community.communityName) { (didSucceed) in
//                if didSucceed {
//                    userIsJoined = false
//                    joinLeaveCommunityText = "Join Community"
//                } else {
//                    print("Error joining/leaving community")
//                }
//            }
//        } else {
//            FirestoreManager.shared.joinCommunity(communityName: community.communityName) { (didSucceed) in
//                if didSucceed {
//                    userIsJoined = true
//                    joinLeaveCommunityText = "Leave Community"
//                } else {
//                    print("Error joining/leaving community")
//                }
//            }
//        }
//    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView(community: Community(id: "", communityName: "Testing", users: [], communityImageURL: ""))
    }
}
