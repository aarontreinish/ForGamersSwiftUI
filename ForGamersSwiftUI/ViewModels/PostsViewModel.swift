//
//  PostsViewModel.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation

class PostsViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    func getUserPosts() {
        var uniquePosts = self.posts
        var counter = 0
        counter += 1
        self.posts.removeAll()
        uniquePosts.removeAll()
        FirestoreManager.shared.getPostsForUserJoinedCommunities { (userJoinedPosts, error) in
            print("GETUSERPOSTS \(counter)")
            if let userJoinedPosts = userJoinedPosts {
                uniquePosts.append(contentsOf: userJoinedPosts)
                self.posts = uniquePosts.unique{ $0.postTitle }
            }
            
            if let error = error {
                print(error)
            }
        }
    }
    
    func getPostsForCommunity(communityName: String) {
        FirestoreManager.shared.getPostsFor(communityName) { (communityPosts, error) in
            if let error = error {
                print(error)
            }
            
            if let communityPosts = communityPosts {
                self.posts = communityPosts
            }
        }
    }
    
}

extension Array {
    func unique<T:Hashable>(by: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(by(value)) {
                set.insert(by(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
