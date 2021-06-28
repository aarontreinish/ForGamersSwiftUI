//
//  ForGamersSwiftUIApp.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI
import Firebase

@main
struct ForGamersSwiftUIApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
      FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                // Set Your home view controller Here as root View Controller
                TabBarView()
            } else {
                // Set you login view controller here as root view controller
                ContentView()
            }
        }
    }
}
