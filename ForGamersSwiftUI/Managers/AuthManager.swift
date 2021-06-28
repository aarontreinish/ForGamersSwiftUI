//
//  AuthManager.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

final class AuthManager {
    
    static let shared = AuthManager()
    
    var counter = 0
    func signUp(username: String, email: String, password: String, selectedProfileImage: UIImage, completion: @escaping (Bool?, String?) -> Void) {
        counter += 1
        print("SIGN UP COUNTER: \(counter)")
        if isValidEmail(email) {
            print("executing Username is taken")
            DatabaseManager.shared.usernameIsTaken(with: username) { (usernameIsTaken) in
                print("Finished checking if Username is taken: \(usernameIsTaken)")
                if usernameIsTaken == true {
                    print("username is taken was true")
                    completion(nil, "Username is taken")
                    return
                } else if usernameIsTaken == false {
                    print("username is taken was false executing creating user")
                    Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
                        print("Finished creating user")
                        if let error = error {
                            print("error creating user")
                            print(error)
                            completion(nil, error.localizedDescription)
                        }
                        
                        if let authData = authDataResult {
                            print(authData)
                            
                            let user = User(username: username, email: email, joinedCommunities: [], upVotedPosts: [], downVotedPosts: [])
                            
                            DatabaseManager.shared.insertUser(with: user) { (didSucceed) in
                                if didSucceed {
                                    UserDefaults.standard.set(email, forKey: "email")
                                    UserDefaults.standard.set(username, forKey: "username")
                                    
                                    // upload image
                                    guard let data = selectedProfileImage.pngData() else { return }
                                    
                                    let fileName = user.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                        switch result {
                                        case .success(let downloadURL):
                                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                            print(downloadURL)
                                            completion(true, nil)
                                        case .failure(let error):
                                            print("Storage manager error: \(error)")
                                            completion(nil, error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    // self?.showErrorAlert(title: "Account not enabled", message: "The email and password you entered are not enabled")
                    completion(false, error)
                    print(error)
                case .userDisabled:
                    // Error: The user account has been disabled by an administrator.
                    //self?.showErrorAlert(title: "User disabled", message: "The user account has been disabled by an administrator.")
                    completion(false, error)
                    print(error)
                case .wrongPassword:
                    // Error: The password is invalid or the user does not have a password.
                    //self?.showErrorAlert(title: "Incorrect password", message: "The password you have entered is incorrect or invalid.")
                    completion(false, error)
                    print(error)
                case .invalidEmail:
                    // Error: Indicates the email address is malformed.
                    //self?.showErrorAlert(title: "Incorrect email", message: "The email you have entered is incorrect or invalid.")
                    completion(false, error)
                    print(error)
                default:
                    //self?.showErrorAlert(title: "Error logging in", message: "There was an error logging in. Please try again later.")
                    completion(false, error)
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signs in successfully")
                UserDefaults.standard.set(email, forKey: "email")
                completion(true, nil)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //present(alert, animated: true, completion: nil)
    }
}


