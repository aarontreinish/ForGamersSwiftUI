//
//  UpVotedPostsViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/9/21.
//

import Foundation

class UpVotedPostsViewModel: ObservableObject {
    @Published var upVotedPosts: [String] = []
    
    func getUserUpVotedPosts() {
        DatabaseManager.shared.getUserUpVotedPosts { (posts) in
            if let posts = posts {
                self.upVotedPosts = posts
            }
        }
    }
    
}
