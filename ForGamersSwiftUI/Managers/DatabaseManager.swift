//
//  DatabaseManager.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    func updateUserForJoining(communityName: String, completion: @escaping ((Bool) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                FirestoreManager.shared.getUserJoinedCommunities { (joinedCommunities) in
                    if let joinedCommunities = joinedCommunities {
                        var communities = joinedCommunities
                        communities.append(communityName)
                        
                        self.database.child("\(safeEmail)").child("joinedCommunities").setValue(communities) { (error, _) in
                            if let error = error {
                                print(error)
                                completion(false)
                            }
                            completion(true)
                        }
                    } else {
                        var communities: [String] = []
                        communities.append(communityName)
                        
                        self.database.child("\(safeEmail)").child("joinedCommunities").setValue(communities) { (error, _) in
                            if let error = error {
                                print(error)
                                completion(false)
                            }
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func updateUserForLeaving(communityName: String, completion: @escaping ((Bool) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                FirestoreManager.shared.getUserJoinedCommunities { (joinedCommunities) in
                    if let joinedCommunities = joinedCommunities {
                        var communities = joinedCommunities
                        
                        if communities.contains(communityName) {
                            communities = communities.filter { $0 != communityName }
                            
                            self.database.child("\(safeEmail)").child("joinedCommunities").setValue(communities) { (error, _) in
                                if let error = error {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUserUpVotedPosts(completion: @escaping (([String]?) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                Database.database().reference().child("\(safeEmail)").child("upVotedPosts").observeSingleEvent(of: .value) { (snapshot) in
                    let value = snapshot.value as? [String]
                    
                    completion(value)
                }
            }
        }
    }
    
    func getUserDownVotedPosts(completion: @escaping (([String]?) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                Database.database().reference().child("\(safeEmail)").child("downVotedPosts").observeSingleEvent(of: .value) { (snapshot) in
                    let value = snapshot.value as? [String]
                    
                    completion(value)
                }
            }
        }
    }
    
    func userUpVoted(post: Post, completion: @escaping ((Bool) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                var downVotedPosts: [String] = []
                
                getUserDownVotedPosts { (posts) in
                    if let posts = posts {
                        downVotedPosts = posts
                    }
                }
                
                getUserUpVotedPosts { (upVotedPosts) in
                    if var upVotedPosts = upVotedPosts {
                        if upVotedPosts.contains(post.postTitle) {
                            upVotedPosts.removeAll { $0 == post.postTitle }
                            
                            self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // up vote increment -1
                                FirestoreManager.shared.decrementUpVoteCount(post: post)
                                
                                completion(true)
                            }
                        } else if downVotedPosts.contains(post.postTitle) {
                            downVotedPosts.removeAll { $0 == post.postTitle }
                            
                            self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // down vote increment -1
                                FirestoreManager.shared.decrementDownVoteCount(post: post)
                                
                                upVotedPosts.append(post.postTitle)
                                self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                                    if let error = error {
                                        print(error)
                                        completion(false)
                                    }
                                    
                                    //up vote incremetnt +1
                                    FirestoreManager.shared.incrementUpVoteCount(post: post)
                                    
                                    completion(true)
                                }
                            }
                        } else {
                            upVotedPosts.append(post.postTitle)
                            
                            self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // up vote increment +1
                                FirestoreManager.shared.incrementUpVoteCount(post: post)
                                
                                completion(true)
                            }
                        }
                    } else if downVotedPosts.contains(post.postTitle) {
                        downVotedPosts.removeAll { $0 == post.postTitle }
                        
                        self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                            if let error = error {
                                print(error)
                            }
                            
                            // down vote increment -1
                            FirestoreManager.shared.decrementDownVoteCount(post: post)
                            
                            var upVotedPosts: [String] = []
                            upVotedPosts.append(post.postTitle)
                            
                            self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // up vote increment +1
                                FirestoreManager.shared.incrementUpVoteCount(post: post)
                                
                                completion(true)
                            }
                        }
                    } else {
                        var upVotedPosts: [String] = []
                        upVotedPosts.append(post.postTitle)
                        
                        self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                            if let error = error {
                                print(error)
                                completion(false)
                            }
                            
                            // up vote increment +1
                            FirestoreManager.shared.incrementUpVoteCount(post: post)
                            
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func userDownVoted(post: Post, completion: @escaping ((Bool) -> Void)) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                var upVotedPosts: [String] = []
                
                getUserUpVotedPosts { (posts) in
                    if let posts = posts {
                        upVotedPosts = posts
                    }
                }
                
                getUserDownVotedPosts { (downVotedPosts) in
                    if var downVotedPosts = downVotedPosts {
                        if downVotedPosts.contains(post.postTitle) {
                            downVotedPosts.removeAll { $0 == post.postTitle }
                            
                            self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // down vote increment -1
                                FirestoreManager.shared.decrementDownVoteCount(post: post)
                                
                                completion(true)
                            }
                        } else if upVotedPosts.contains(post.postTitle) {
                            upVotedPosts.removeAll { $0 == post.postTitle }
                            
                            self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // up vote increment -1
                                FirestoreManager.shared.decrementUpVoteCount(post: post)
                                
                                downVotedPosts.append(post.postTitle)
                                self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                                    if let error = error {
                                        print(error)
                                        completion(false)
                                    }
                                    
                                    //down vote incremetnt +1
                                    FirestoreManager.shared.incrementDownVoteCount(post: post)
                                    
                                    completion(true)
                                }
                            }
                        } else {
                            downVotedPosts.append(post.postTitle)
                            
                            self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // down vote increment +1
                                FirestoreManager.shared.incrementDownVoteCount(post: post)
                                
                                completion(true)
                            }
                        }
                    } else if upVotedPosts.contains(post.postTitle) {
                        upVotedPosts.removeAll { $0 == post.postTitle }
                        
                        self.database.child("\(safeEmail)").child("upVotedPosts").setValue(upVotedPosts) { (error, _) in
                            if let error = error {
                                print(error)
                            }
                            
                            // up vote increment -1
                            FirestoreManager.shared.decrementUpVoteCount(post: post)
                            
                            var downVotedPosts: [String] = []
                            downVotedPosts.append(post.postTitle)
                            
                            self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                                if let error = error {
                                    print(error)
                                    completion(false)
                                }
                                
                                // down vote increment +1
                                FirestoreManager.shared.incrementDownVoteCount(post: post)
                                
                                completion(true)
                            }
                        }
                    } else {
                        var downVotedPosts: [String] = []
                        downVotedPosts.append(post.postTitle)
                        
                        self.database.child("\(safeEmail)").child("downVotedPosts").setValue(downVotedPosts) { (error, _) in
                            if let error = error {
                                print(error)
                                completion(false)
                            }
                            
                            // down vote increment +1
                            FirestoreManager.shared.incrementDownVoteCount(post: post)
                            
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func usernameIsTaken(with username: String, completion: @escaping ((Bool) -> Void)) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let users = snapshot.value as? [[String: String]] else {
                completion(true)
                return
            }
            
            //where: {$0["QUESTIONID"] == dic["QUESTIONID"]}
            if users.contains(where: { $0["username"] == username }) {
                completion(true)
            } else {
                completion(false)
            }
        }
//        database.child(username).observeSingleEvent(of: .value) { (snapshot) in
//            guard snapshot.value as? String != nil else {
//                completion(false)
//                return
//            }
//
//            completion(true)
//        }
    }
    
    /// Insert new user database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "username": user.username,
            "joinedCommunities": user.joinedCommunities
        ]) { (error, databaseRefernce) in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newElement = [
                        "username": user.username,
                        "email": user.safeEmail,
                    ]
                    
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                } else {
                    let newCollection: [[String: String]] = [
                        [
                            "username": user.username,
                            "email": user.safeEmail,
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
}

// MARK: - Sending messages / conversations
//extension DatabaseManager {
//
//    /// Creates a new conversation with target user and first message sent
//    public func createNewConversation(with otherUserEmail: String, username: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String, let currentUsername = UserDefaults.standard.value(forKey: "username") else { return }
//
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
//
//        let ref = database.child("\(safeEmail)")
//        ref.observeSingleEvent(of: .value) { [weak self] (snapshot) in
//            guard var userNode = snapshot.value as? [String: Any] else {
//                completion(false)
//                print("User not found")
//                return
//            }
//
//            let messageDate = firstMessage.sentDate
//            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
//
//            var message = ""
//
//            switch firstMessage.kind {
//            case .text(let messageText):
//                message = messageText
//            case .attributedText(_):
//                break
//            case .photo(_):
//                break
//            case .video(_):
//                break
//            case .location(_):
//                break
//            case .emoji(_):
//                break
//            case .audio(_):
//                break
//            case .contact(_):
//                break
//            case .linkPreview(_):
//                break
//            case .custom(_):
//                break
//            }
//
//            let conversationId = "conversation_\(firstMessage.messageId)"
//
//            let newConversationData: [String: Any] = [
//                "id": conversationId,
//                "other_user_email": otherUserEmail,
//                "username": username,
//                "latest_message": [
//                    "date": dateString,
//                    "message": message,
//                    "is_read": false
//                ]
//            ]
//
//            let recipient_newConversationData: [String: Any] = [
//                "id": conversationId,
//                "other_user_email": safeEmail,
//                "username": currentUsername,
//                "latest_message": [
//                    "date": dateString,
//                    "message": message,
//                    "is_read": false
//                ]
//            ]
//
//            // update recipient conversation entry
//            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
//                if var conversations = snapshot.value as? [[String: Any]] {
//                    //append
//                    conversations.append(recipient_newConversationData)
//                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
//                } else {
//                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
//                }
//            }
//
//
//            // update current user conversation entry
//            if var conversations = userNode["conversations"] as? [[String: Any]] {
//                conversations.append(newConversationData)
//                userNode["conversations"] = conversations
//                ref.setValue(userNode, withCompletionBlock: { [weak self] (error, _) in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    self?.finishCreatingConversation(conversationID: conversationId, username: username, firstMessage: firstMessage, completion: completion)
//
//                })
//            } else {
//                userNode["conversations"] = [
//                    newConversationData
//                ]
//
//                ref.setValue(userNode, withCompletionBlock: { [weak self] (error, _) in
//                    guard error == nil else {
//                        completion(false)
//                        return
//                    }
//                    self?.finishCreatingConversation(conversationID: conversationId, username: username, firstMessage: firstMessage, completion: completion)
//                })
//            }
//        }
//    }
//
//    private func finishCreatingConversation(conversationID: String, username: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        var message = ""
//
//        let messageDate = firstMessage.sentDate
//        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
//
//        switch firstMessage.kind {
//        case .text(let messageText):
//            message = messageText
//        case .attributedText(_):
//            break
//        case .photo(_):
//            break
//        case .video(_):
//            break
//        case .location(_):
//            break
//        case .emoji(_):
//            break
//        case .audio(_):
//            break
//        case .contact(_):
//            break
//        case .linkPreview(_):
//            break
//        case .custom(_):
//            break
//        }
//
//        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
//            completion(false)
//            return
//        }
//
//        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
//
//        let collectionMessage: [String: Any] = [
//            "id": firstMessage.messageId,
//            "type": firstMessage.kind.messageKindString,
//            "content": message,
//            "date": dateString,
//            "sender_email": currentUserEmail,
//            "is_read": false,
//            "username": username
//        ]
//
//        let value: [String: Any] = [
//            "messages": [
//                collectionMessage
//            ]
//        ]
//
//        database.child("\(conversationID)").setValue(value) { (error, reference) in
//            guard error == nil else {
//                completion(false)
//                return
//            }
//
//            completion(true)
//        }
//    }
//
//    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
//        database.child("\(email)/conversations").observe(.value) { (snapshot) in
//            guard let value = snapshot.value as? [[String: Any]] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            let conversations: [Conversation] = value.compactMap { (dictionary)  in
//                guard let conversationId = dictionary["id"] as? String, let name = dictionary["username"] as? String, let otherUserEmail = dictionary["other_user_email"] as? String, let latestMessage = dictionary["latest_message"] as? [String: Any], let date = latestMessage["date"] as? String, let message = latestMessage["message"] as? String, let isRead = latestMessage["is_read"] as? Bool else {
//                    return nil
//                }
//
//                let latestMessageObject = LatestMessage(message: message, date: date, isRead: isRead)
//
//                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
//            }
//
//            completion(.success(conversations))
//        }
//    }
//
//    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
//        database.child("\(id)/messages").observe(.value) { (snapshot) in
//            guard let value = snapshot.value as? [[String: Any]] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }
//
//            let messages: [Message] = value.compactMap { (dictionary)  in
//                guard let name = dictionary["username"] as? String, let isRead = dictionary["is_read"] as? Bool, let messageId = dictionary["id"] as? String, let content = dictionary["content"] as? String, let senderEmail = dictionary["sender_email"] as? String, let dateString = dictionary["date"] as? String, let type = dictionary["type"] as? String, let date = ChatViewController.dateFormatter.date(from: dateString) else {
//                    return nil
//                }
//
//                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
//
//                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
//            }
//
//            completion(.success(messages))
//        }
//    }
//
//    public func sendMessage(to conversation: String, otherUserEmail: String, username: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
//
//        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
//            completion(false)
//            return
//        }
//
//        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
//
//        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
//            guard let strongSelf = self else { return }
//
//            guard var currentMessages = snapshot.value as? [[String: Any]] else {
//                completion(false)
//                return
//            }
//
//            let messageDate = newMessage.sentDate
//            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
//
//            var message = ""
//            switch newMessage.kind {
//            case .text(let messageText):
//                message = messageText
//            case .attributedText(_):
//                break
//            case .photo(_):
//                break
//            case .video(_):
//                break
//            case .location(_):
//                break
//            case .emoji(_):
//                break
//            case .audio(_):
//                break
//            case .contact(_):
//                break
//            case .linkPreview(_):
//                break
//            case .custom(_):
//                break
//            }
//
//            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
//                completion(false)
//                return
//            }
//
//            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
//
//            let newMessageEntry: [String: Any] = [
//                "id": newMessage.messageId,
//                "type": newMessage.kind.messageKindString,
//                "content": message,
//                "date": dateString,
//                "sender_email": currentUserEmail,
//                "is_read": false,
//                "username": username
//            ]
//
//            currentMessages.append(newMessageEntry)
//
//            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { (error, _) in
//                guard error == nil else {
//                    completion(false)
//                    return
//                }
//
//                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
//                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
//                        completion(false)
//                        return
//                    }
//
//                    var targetConversation: [String: Any]?
//
//                    var position = 0
//
//                    let updatedValue: [String: Any] = [
//                        "date": dateString,
//                        "is_read": false,
//                        "message": message
//                    ]
//
//                    for conversationDictionary in currentUserConversations {
//                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
//                            targetConversation = conversationDictionary
//                            break
//                        }
//                        position += 1
//                    }
//
//                    targetConversation?["latest_message"] = updatedValue
//                    guard let finalConversation = targetConversation else {
//                        completion(false)
//                        return
//                    }
//                    currentUserConversations[position] = finalConversation
//                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations) { (error, _) in
//                        guard error == nil else {
//                            completion(false)
//                            return
//                        }
//
//                        // update latest message for recipient user
//                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
//                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
//                                completion(false)
//                                return
//                            }
//
//                            var targetConversation: [String: Any]?
//
//                            var position = 0
//
//                            let updatedValue: [String: Any] = [
//                                "date": dateString,
//                                "is_read": false,
//                                "message": message
//                            ]
//
//                            for conversationDictionary in otherUserConversations {
//                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
//                                    targetConversation = conversationDictionary
//                                    break
//                                }
//                                position += 1
//                            }
//
//                            targetConversation?["latest_message"] = updatedValue
//                            guard let finalConversation = targetConversation else {
//                                completion(false)
//                                return
//                            }
//                            otherUserConversations[position] = finalConversation
//                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { (error, _) in
//                                guard error == nil else {
//                                    completion(false)
//                                    return
//                                }
//                                completion(true)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}
