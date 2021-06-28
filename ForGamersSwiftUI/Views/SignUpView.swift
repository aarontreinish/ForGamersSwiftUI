//
//  SignUpView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct SignUpView: View {
    @State var showSpinner = false
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isShowPhotoLibrary = false
    @State private var image: UIImage?
    @State private var isPresented = false
    @State var showsAlert = false
    @State var errorString = ""
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowPhotoLibrary = true
                    }, label: {

                        Image(uiImage: self.image ?? UIImage(systemName: "person")!)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    })
                    .sheet(isPresented: $isShowPhotoLibrary) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(Color.secondary)
                    .clipShape(Circle())
                    Spacer()
                }

                TextField("Username", text: self.$username)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                
                TextField("Email", text: self.$email)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                
                Button(action: {
                    self.showSpinner.toggle()
                    AuthManager.shared.signUp(username: username, email: email, password: password, selectedProfileImage: image ?? UIImage(systemName: "person")!) { (didSignUp, error) in
                        if let error = error {
                            self.showsAlert.toggle()
                            self.errorString = error
                        }
                        
                        if let didSignUp = didSignUp {
                            if didSignUp == true {
                                self.showSpinner = false
                                self.isPresented.toggle()
                            }
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                        .shadow(radius: 10.0, x: 20, y: 10)
                }.padding(.top, 50)
                .fullScreenCover(isPresented: $isPresented, content: {
                    OnboardingView()
                })
                .alert(isPresented: self.$showsAlert) {
                    Alert(
                        title: Text("Error signing up"),
                        message: Text("\(errorString)"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.padding([.leading, .trailing], 27.5)
            
            if showSpinner {
              SpinnerView()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
