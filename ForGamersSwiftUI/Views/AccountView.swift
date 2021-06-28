//
//  AccountView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/5/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct AccountView: View {
    @State var user: UserInfo?
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            if let user = user {
                AsyncImage(url: URL(string: user.profileImageURL)!,
                           placeholder: { ProgressView() },
                           image: { Image(uiImage: $0).resizable() })
                    .clipShape(Circle())
                    .frame(width: 100, height: 100, alignment: .center)
                
                Text("Username: \(user.username)")
                Text("Email: \(user.email)")
                Text("Joined Communities: \(user.joinedCommunities.joined(separator:", "))")
                
                Spacer()
                Button("Logout") {
                    do {
                        try Auth.auth().signOut()
                        self.isPresented.toggle()
                    } catch {
                        print("Sign out error")
                    }
                }.fullScreenCover(isPresented: $isPresented, content: {
                    ContentView()
                })
            }
            
            
        }
        .onAppear {
            StorageManager.shared.getUserInfo { (userInfo, error) in
                if let error = error {
                    print(error)
                }
                
                if let userInfo = userInfo {
                    self.user = userInfo
                }
            }
        }
    }
    

}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
