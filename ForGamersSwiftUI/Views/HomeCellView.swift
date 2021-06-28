//
//  HomeCellView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/8/21.
//

import SwiftUI

struct HomeCellView: View {
    @ObservedObject var upVotedPostsViewModel = UpVotedPostsViewModel()
    @ObservedObject var downVotedPostsViewModel = DownVotedPostsViewModel()
    
    let post: Post
    
    @State var isPostViewPresented = false
    
    static let taskDateFormat: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: post.communityImageURL)!,
                           placeholder: { ProgressView() },
                           image: { Image(uiImage: $0).resizable() })
                    .clipShape(Circle())
                    .frame(width: 50, height: 50, alignment: .center)
                
                VStack(alignment: .leading) {
                    Text(post.communityName)
                        .font(.subheadline)
                    Text(post.user)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(post.createdAt, formatter: Self.taskDateFormat)")
                    .font(.subheadline)
                
            }
            .padding(.bottom)
            
            HStack {
                Spacer()
                Text(post.postTitle)
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom)
            
            if post.imageURL != "" {
                AsyncImage(url: URL(string: post.imageURL)!,
                           placeholder: { ProgressView() },
                           image: { Image(uiImage: $0).resizable() })
                    .frame(width: UIScreen.main.bounds.width - 20, height: 200, alignment: .center)
            }
            
            HStack {
                Image(systemName: "captions.bubble.fill")
                Text("\(post.comments.count)")
                Spacer()
                
                HStack {
                    Button(action: {
                        DatabaseManager.shared.userUpVoted(post: post) { (didUpVote) in
                            print("DID UP VOTE \(didUpVote)")
                        }
                    }, label: {
                        Image(systemName: upVotedPostsViewModel.upVotedPosts.contains(post.postTitle) ? "arrow.up.square.fill" : "arrow.up.square")
//                        if upVotedPostsViewModel.upVotedPosts.contains(post.postTitle) {
//                            Image(systemName: "arrow.up.square.fill")
//                        } else {
//                            Image(systemName: "arrow.up.square")
//                        }
                    })
                    Text("\(post.upVoteCount)")
                    
                    Button(action: {
                        DatabaseManager.shared.userDownVoted(post: post) { (didDownVote) in
                            print("DID DOWN VOTE \(didDownVote)")
                        }
                    }, label: {
                        Image(systemName: downVotedPostsViewModel.downVotedPosts.contains(post.postTitle) ? "arrow.down.square.fill" : "arrow.down.square")
                        
//                        if downVotedPostsViewModel.downVotedPosts.contains(post.postTitle) {
//                            Image(systemName: "arrow.down.square.fill")
//                        } else {
//                            Image(systemName: "arrow.down.square")
//                        }
                    })
                    Text("\(post.downVoteCount)")
                }
            }
        }
        .onAppear {
            //postviewModel.getPost(passedPost: post)
            upVotedPostsViewModel.getUserUpVotedPosts()
            downVotedPostsViewModel.getUserDownVotedPosts()
        }
        .frame(width: UIScreen.main.bounds.width - 20)
        .onTapGesture {
            self.isPostViewPresented.toggle()
        }
        .sheet(isPresented: $isPostViewPresented, content: {
            PostView(post: post)
        })
    }
}

struct HomeCellView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCellView(post: Post(postTitle: "Testing testing testing", downVoteCount: 10, upVoteCount: 100, user: "testinguser", createdAt: Date(), comments: [], communityName: "Kaito Communtiy", communityImageURL: "https://firebasestorage.googleapis.com/v0/b/forgamers-c4831.appspot.com/o/communityImages%2FKaito%20community_image.png?alt=media&token=0c101604-e92b-49a7-8964-2167571f1cdf", imageURL: "", videoURL: ""))
    }
}
