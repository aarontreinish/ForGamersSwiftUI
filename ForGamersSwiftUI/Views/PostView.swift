//
//  PostView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct PostView: View {
    var post: Post
    
    @ObservedObject var viewModel = CommentsViewModel()
    @ObservedObject var postviewModel = PostViewModel()
    
    @State var text: String = ""
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack {
                        HStack {
                            Text(postviewModel.post.communityName)
                                .padding(.leading)
                            Spacer()
                            Text("\(postviewModel.post.createdAt, formatter: Self.taskDateFormat)")
                                .padding(.trailing)
                        }
                        Text(postviewModel.post.user)
                            .padding()
                        Text(postviewModel.post.postTitle)
                            .padding()
                        if postviewModel.post.imageURL != "" {
                            HStack {
                                Spacer()
                                AsyncImage(url: URL(string: postviewModel.post.imageURL)!,
                                           placeholder: { ProgressView() },
                                           image: { Image(uiImage: $0).resizable() })
                                    .cornerRadius(4.0)
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .aspectRatio(contentMode: .fit)
                                Spacer()
                            }
                        }
                        HStack {
                            Spacer()
                            Text("Up Vote: \(postviewModel.post.upVoteCount)")
                            Spacer()
                            Text("Down Vote: \(postviewModel.post.downVoteCount)")
                            Spacer()
                            Text("Comments: \(postviewModel.post.comments.count)")
                            Spacer()
                        }
                    }
                }
                ForEach(postviewModel.post.comments, id: \.self) { comment in
                    VStack {
                        HStack {
                            Text(comment.user)
                            Spacer()
                            Text("\(comment.createdAt, formatter: Self.taskDateFormat)")
                            
                        }
                        Text(comment.commentText)
                    }
                }
            }
            
            HStack {
                TextField("Message...", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                Button(action: {
                    addComment()
                }, label: {
                    Text("Comment")
                })
                .disabled(text.isEmpty)
            }.frame(minHeight: CGFloat(50)).padding()
        }
        .onAppear {
            viewModel.post = post
            viewModel.setData()
            postviewModel.getPost(passedPost: post)
        }
    }
    
    func addComment() {
        //guard let text = text, !text.isEmpty else { return }
        if text == "" {
            
        }
        FirestoreManager.shared.addComment(commentText: text, post: post) { (comment, error) in
            if let error = error {
                print(error)
            }
            
            if let comment = comment {
                //comments.append(comment)
                viewModel.comment = comment
                viewModel.addComment()
            }
        }
        
        self.text = ""
    }
}


//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView(post: Post(id: "", postTitle: "Great Post", downVoteCount: 10, upVoteCount: 100, user: "testing", createdAt: Date(), comments: [], community: "Kaito Community", imageURL: "gs://forgamers-c4831.appspot.com/postImages/Kaito community/Test image_image.png", videoURL: ""))
//    }
//}
