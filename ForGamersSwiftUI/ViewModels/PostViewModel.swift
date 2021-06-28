//
//  PostViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/3/21.
//

import Foundation

class PostViewModel: ObservableObject {
    @Published var post = Post(id: "", postTitle: "", downVoteCount: 0, upVoteCount: 0, user: "", createdAt: Date(), comments: [], communityName: "", communityImageURL: "", imageURL: "", videoURL: "")
    
    func getPost(passedPost: Post) {
        FirestoreManager.shared.getPost(post: passedPost) { (observedPost, error) in
            if let error = error {
                print(error)
            }
            
            if let observedPost = observedPost {
                self.post = observedPost
            }
        }
    }
    
}

//class PostViewModel: ObservableObject {
//    @Published private(set) var post: Post
//    private var cancellable: AnyCancellable?
//
//    init<T: Publisher>(
//        post: Post,
//        publisher: T
//    ) where T.Output == Post, T.Failure == Never {
//        self.post = post
//        self.cancellable = publisher.assign(to: \.post, on: self)
//    }
//
//    func setData(passedPost: Post) {
//        post = passedPost
//    }
//
//    func getPost() {
//        FirestoreManager.shared.getPost(post: post) { (returnedPost, error) in
//            if let error = error {
//                print(error)
//            }
//
//            if let returnedPost = returnedPost {
//                self.post = returnedPost
//            }
//        }
//    }
//}

//class PostViewModel: ObservableObject {
//    @Published var post: Post
//
//    init(initPost: Post) {
//        self.post = initPost
//    }
//
//}
