//
//  FirestoreManager.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

final class FirestoreManager {
    
    static let shared = FirestoreManager()
    var ref: DatabaseReference!
    let db = Firestore.firestore()
    
    var joinedCommunities: [String] = []
    
    func getCurrentUser() {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                Database.database().reference().child(safeEmail).child("username").observeSingleEvent(of: .value) { (snapshot) in
                    guard let value = snapshot.value as? String else {
                        return
                    }
                    UserDefaults.standard.set(value, forKey: "username")
                }
                
            }
        }
    }
    
    func getCommunities(completion: @escaping (([Community]?, Error?) -> Void)) {
        var communities: [Community] = []
        
        let communitiesCollections = db.collection("communities")
        communitiesCollections.addSnapshotListener { (querySnapshot, error) in
            if let error = error as NSError? {
                print("Error getting document: \(error.localizedDescription)")
                completion(nil, error)
            }
            else {
                if let querySnapshot = querySnapshot {
                    communities = querySnapshot.documents.compactMap { document -> Community? in
                        try? document.data(as: Community.self)
                    }
                    completion(communities, nil)
                }
            }
        }
    }
    
    func getPostsFor(_ communityName: String, completion: @escaping (([Post]?, Error?) -> Void)) {
        var posts: [Post] = []
        
        db.collection("communities").document(communityName).collection("Posts").addSnapshotListener { querySnapshot, error in
            if let error = error as NSError? {
                print("Error getting document: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let querySnapshot = querySnapshot {
                    posts = querySnapshot.documents.compactMap { document -> Post? in
                        try? document.data(as: Post.self)
                    }
                    completion(posts, nil)
                }
            }
        }
    }
    
    func getPost(post: Post, completion: @escaping ((Post?, Error?) -> Void)) {
        db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle).addSnapshotListener { (querySnapshot, error) in
            if let error = error as NSError? {
                print("Error getting document: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let querySnapshot = querySnapshot {
                    do {
                        let post = try querySnapshot.data(as: Post.self)
                        completion(post, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func getPostsForUserJoinedCommunities(completion: @escaping (([Post]?, Error?) -> Void)) {
        var counter = 0
        getUserJoinedCommunities { [weak self] (communities) in
            if let communities = communities {
                for community in communities {
                    self?.getPostsFor(community) { (posts, error) in
                        if let error = error {
                            print(error)
                            completion(nil, error)
                        }
                        
                        if let posts = posts {
                            counter += 1
                            print(counter)
                            completion(posts, nil)
                        }
                    }
                }
            }
        }
    }
    
    func getUserJoinedCommunities(completion: @escaping (([String]?) -> Void)) {
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                self.ref.child("\(safeEmail)").child("joinedCommunities").observeSingleEvent(of: .value) { (snapshot) in
                    let value = snapshot.value as? [String]
                    
                    completion(value)
                }
            }
        }
    }
    
    func addComment(commentText: String, post: Post, completion: @escaping (Comments?, Error?) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            if user.email != nil {
                //guard let commentText = addCommentTextView.text else { return }
                
                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                let comment = Comments(commentText: commentText, user: username, createdAt: Date())
                var comments = post.comments
                comments.append(comment)
                
                let updatedPost = Post(postTitle: post.postTitle, downVoteCount: post.downVoteCount, upVoteCount: post.upVoteCount, user: post.user, createdAt: post.createdAt, comments: comments, communityName: post.communityName, communityImageURL: post.communityImageURL, imageURL: post.imageURL, videoURL: post.videoURL)
                
                do {
                    let _ = try db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle).setData(from: updatedPost)
                    completion(comment, nil)
                }
                catch {
                    print(error)
                    completion(nil, error)
                }
            }
        }
    }
    
    func joinCommunity(communityName: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let communitiesDocumentRef = db.collection("communities").document(communityName)
                
                communitiesDocumentRef.updateData([
                    "users": FieldValue.arrayUnion([email])
                ]) { (error) in
                    if error != nil {
                        print(error)
                        completion(false)
                    } else {
                        print("User joined successfully")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func leaveCommunity(communityName: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let documentRef = db.collection("communities").document(communityName)
                
                documentRef.updateData([
                    "users": FieldValue.arrayRemove([email])
                ]) { (error) in
                    if error != nil {
                        print(error)
                        completion(false)
                    } else {
                        print("User left successfully")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func submitPost(community: Community, postText: String, selectedImage: UIImage?, mediaURL: URL?, isVideo: Bool, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let comments: [Comments] = []
                
                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                if selectedImage != nil {
                    print("IS VIDEO: \(isVideo)")
                    if isVideo == true {
                        if let mediaURL = mediaURL {
                            uploadPostVideo(mediaURL: mediaURL, communityName: community.communityName, postText: postText) { (videoURL, error) in
                                if let error = error {
                                    print(error)
                                }
                                
                                if let videoURL = videoURL {
                                    
                                    let newPost = Post(postTitle: postText, downVoteCount: 0, upVoteCount: 0, user: username, createdAt: Date(), comments: comments, communityName: community.communityName, communityImageURL: community.communityImageURL, imageURL: "", videoURL: videoURL)
                                    
                                    do {
                                        let _ = try self.db.collection("communities").document(community.communityName).collection("Posts").document(postText).setData(from: newPost)
                                        completion(true)
                                    }
                                    catch {
                                        print(error)
                                        completion(false)
                                    }
                                }
                            }
                        }
                    } else {
                        if let selectedImage = selectedImage {
                            uploadPostImage(image: selectedImage, communityName: community.communityName, postText: postText) { (imageURL, error) in
                                if let error = error {
                                    print(error)
                                }
                                
                                if let imageURL = imageURL {
                                    
                                    let newPost = Post(postTitle: postText, downVoteCount: 0, upVoteCount: 0, user: username, createdAt: Date(), comments: comments, communityName: community.communityName, communityImageURL: community.communityImageURL, imageURL: imageURL, videoURL: "")
                                    
                                    do {
                                        let _ = try self.db.collection("communities").document(community.communityName).collection("Posts").document(postText).setData(from: newPost)
                                        completion(true)
                                    }
                                    catch {
                                        print(error)
                                        completion(false)
                                    }
                                }
                            }
                        }
                    }
                } else {

                    let newPost = Post(postTitle: postText, downVoteCount: 0, upVoteCount: 0, user: username, createdAt: Date(), comments: comments, communityName: community.communityName, communityImageURL: community.communityImageURL, imageURL: "", videoURL: "")
                    
                    do {
                        let _ = try self.db.collection("communities").document(community.communityName).collection("Posts").document(postText).setData(from: newPost)
                        completion(true)
                    }
                    catch {
                        print(error)
                        completion(false)
                    }
                }
            }
        }
    }
    
    private func uploadPostImage(image: UIImage, communityName: String, postText: String, completion: @escaping (String?, Error?) -> Void) {
        guard let data = image.pngData() else { return }
        
        let fileName = "\(communityName)/\(postText)_image.png"

        StorageManager.shared.uploadPostPicture(with: data, fileName: fileName) { (result) in
            switch result {
            case .success(let downloadURL):
                print(downloadURL)
                completion(downloadURL, nil)
            case .failure(let error):
                print("Storage manager error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    private func uploadPostVideo(mediaURL: URL, communityName: String, postText: String, completion: @escaping (String?, Error?) -> Void) {
        let fileName = "\(communityName)/\(postText)_video.mov"
        
        StorageManager.shared.uploadPostVideo(with: mediaURL, fileName: fileName) { (result) in
            switch result {
            case .success(let downloadURL):
                print(downloadURL)
                completion(downloadURL, nil)
            case .failure(let error):
                print("Storage manager error: \(error)")
                completion(nil, error)
            }
        }
        
    }
    
    func incrementUpVoteCount(post: Post) {
        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
        
        postRef.updateData([
            "upVoteCount": FieldValue.increment(Int64(1))
        ]) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func decrementUpVoteCount(post: Post) {
        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
        
        postRef.updateData([
            "upVoteCount": FieldValue.increment(Int64(-1))
        ]) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func incrementDownVoteCount(post: Post) {
        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
        
        postRef.updateData([
            "downVoteCount": FieldValue.increment(Int64(1))
        ]) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func decrementDownVoteCount(post: Post) {
        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
        
        postRef.updateData([
            "downVoteCount": FieldValue.increment(Int64(-1))
        ]) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
//    func upVote(post: Post) {
//        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
//
//        if post.didDownVote {
//            postRef.updateData([
//                "didUpVote": true,
//                "didDownVote": false,
//                "downVoteCount": FieldValue.increment(Int64(-1)),
//                "upVoteCount": FieldValue.increment(Int64(1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//
//        } else if post.didUpVote {
//            postRef.updateData([
//                "didUpVote": false,
//                "didDownVote": false,
//                "upVoteCount": FieldValue.increment(Int64(-1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//        } else if post.didUpVote && post.didDownVote == false {
//            postRef.updateData([
//                "didUpVote": true,
//                "didDownVote": false,
//                "upVoteCount": FieldValue.increment(Int64(1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//        }
//    }
//
//    func downVote(post: Post) {
//        let postRef = db.collection("communities").document(post.communityName).collection("Posts").document(post.postTitle)
//
//        if post.didDownVote {
//            postRef.updateData([
//                "didUpVote": false,
//                "didDownVote": false,
//                "downVoteCount": FieldValue.increment(Int64(-1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//
//        } else if post.didUpVote {
//            postRef.updateData([
//                "didUpVote": false,
//                "didDownVote": true,
//                "downVoteCount": FieldValue.increment(Int64(1)),
//                "upVoteCount": FieldValue.increment(Int64(-1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//        } else if post.didUpVote && post.didDownVote == false {
//            postRef.updateData([
//                "didUpVote": true,
//                "didDownVote": true,
//                "downVoteCount": FieldValue.increment(Int64(1))
//            ]) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//        }
//    }
    
}
