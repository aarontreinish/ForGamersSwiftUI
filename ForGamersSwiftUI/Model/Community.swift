//
//  Community.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Community: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let communityName: String
    //var posts: [Posts] = []
    var users: [String] = []
    var communityImageURL: String
}

struct Post: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let postTitle: String
    let downVoteCount: Int
    let upVoteCount: Int
    let user: String
    let createdAt: Date
    let comments: [Comments]
    let communityName: String
    let communityImageURL: String
    let imageURL: String
    let videoURL: String
}

struct Comments: Codable, Hashable {
    let commentText: String
    let user: String
    let createdAt: Date
}

struct UserInfo {
    let username: String
    let email: String
    let joinedCommunities: [String]
    let profileImageURL: String
}

struct AllUsers: Codable {
    let username: String
    let email: String
}

struct User: Codable {
    let username: String
    let email: String
    let joinedCommunities: [String]
    let upVotedPosts: [Post]
    let downVotedPosts: [Post]
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}

// MARK: - Conversation
struct Conversation: Codable {
    let id: String?
    let latestMessage: LatestMessage?
    let otherUserEmail: String?
    let username: String?

}

// MARK: - LatestMessage
struct LatestMessage: Codable {
    let date: String?
    let isRead: Bool?
    let message: String?

}

//struct Message: MessageType {
//    var sender: SenderType
//    var messageId: String
//    var sentDate: Date
//    var kind: MessageKind
//
//}
//
//extension MessageKind {
//    var messageKindString: String {
//        switch self {
//        case .text(_):
//            return "text"
//        case .attributedText(_):
//            return "attributedText"
//        case .photo(_):
//            return "photo"
//        case .video(_):
//            return "video"
//        case .location(_):
//            return "location"
//        case .emoji(_):
//            return "emoji"
//        case .audio(_):
//            return "audio"
//        case .contact(_):
//            return "contact"
//        case .linkPreview(_):
//            return "linkPreview"
//        case .custom(_):
//            return "custom"
//        }
//    }
//}
//
//struct Sender: SenderType {
//    var photoURL: String
//    var senderId: String
//    var displayName: String
//}
