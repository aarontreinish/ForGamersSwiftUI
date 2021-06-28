//
//  StorageManager.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns url string
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    func getUserInfo(completion: @escaping (UserInfo?, Error?) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String, let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
        
        FirestoreManager.shared.getUserJoinedCommunities { [weak self] (communities) in
            if let communities = communities {
                self?.getUserProfilePicture { (url, error) in
                    if let error = error {
                        print(error)
                        completion(nil, error)
                    }
                    
                    if let url = url {
                        let user = UserInfo(username: username, email: email, joinedCommunities: communities, profileImageURL: url)
                        completion(user, nil)
                    }
                }
            }
        }
    }
    
    func getUserObject(completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            if let email = currentUser.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                let fileName = safeEmail + "_profile_picture.png"
//
//                let path = "images/" + fileName
//
//                StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
//                    switch result {
//                    case .success(let url):
//                        print(url)
//                        self?.downloadImage(url: url)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
                
                Database.database().reference().child("\(safeEmail)").observeSingleEvent(of: .value) { (snapshot) in
                    guard let value = snapshot.value as? User else {
                        return
                    }
                    
                    //self?.user = value
                    completion(value, nil)
                }
                
            }
        }
    }
    
    func getUserProfilePicture(completion: @escaping (String?, Error?) -> Void ) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            if let email = currentUser.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let fileName = safeEmail + "_profile_picture.png"
                
                let path = "images/" + fileName
                
                StorageManager.shared.downloadURL(for: path) { (result) in
                    switch result {
                    case .success(let url):
                        print(url)
                        let urlString = url.absoluteString
                        completion(urlString, nil)
                    case .failure(let error):
                        print(error)
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    public func uploadCommunityPicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("communityImages/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("communityImages/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public func uploadPostPicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("postImages/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("postImages/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public func uploadPostVideo(with fileURL: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        DispatchQueue.main.async {
            self.storage.child("postVideos/\(fileName)").putFile(from: fileURL, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    print("ERROR: \(error)")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self.storage.child("postVideos/\(fileName)").downloadURL { (url, error) in
                    guard let url = url else {
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print(urlString)
                    completion(.success(urlString))
                }
            }
        }
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
