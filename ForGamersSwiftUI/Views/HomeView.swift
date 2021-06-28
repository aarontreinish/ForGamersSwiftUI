//
//  HomeView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var upVotedPostsViewModel = UpVotedPostsViewModel()
    @ObservedObject var downVotedPostsViewModel = DownVotedPostsViewModel()
    
    //let post: Post
    
    @State var isPostViewPresented = false
    
    static let taskDateFormat: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    @ObservedObject var viewModel = PostsViewModel()
    
    @State var isPresented = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("For Gamers")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            ZStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.posts) { post in
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
                                        })
                                        Text("\(post.upVoteCount)")
                                        
                                        Button(action: {
                                            DatabaseManager.shared.userDownVoted(post: post) { (didDownVote) in
                                                print("DID DOWN VOTE \(didDownVote)")
                                            }
                                        }, label: {
                                            Image(systemName: downVotedPostsViewModel.downVotedPosts.contains(post.postTitle) ? "arrow.down.square.fill" : "arrow.down.square")
                                        })
                                        Text("\(post.downVoteCount)")
                                    }
                                }
                            }
                            .padding(.bottom)
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
                    .frame(width: UIScreen.main.bounds.width)
                }
                .frame(width: UIScreen.main.bounds.width)
                
                .navigationBarTitle("For Gamers")
                .onAppear() {
                    self.viewModel.getUserPosts()
                    FirestoreManager.shared.getCurrentUser()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.isPresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color.white)
                                .padding()
                        })
                        .background(Color.red)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding()
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                        .sheet(isPresented: $isPresented, content: {
                            NewPostView()
                        })
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
