//
//  DownVotedPostsViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/9/21.
//

import Foundation

class DownVotedPostsViewModel: ObservableObject {
    @Published var downVotedPosts: [String] = []
    
    func getUserDownVotedPosts() {
        DatabaseManager.shared.getUserDownVotedPosts { (posts) in
            if let posts = posts {
                self.downVotedPosts = posts
            }
        }
    }
    
}
