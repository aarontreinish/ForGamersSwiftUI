//
//  CommentsViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation

class CommentsViewModel: ObservableObject {
    @Published var comments = [Comments]()
    
    var comment: Comments?
    var post: Post?
    

//    init(post: Post, comment: Comments) {
//        self.post = post
//        comments = post.comments
//        self.comment = comment
//    }
    
    func setData() {
        if let postComments = post?.comments {
            comments = postComments
        }
    }
    
    func addComment() {
        if let comment = comment {
            comments.append(comment)
        }
    }
    
}
