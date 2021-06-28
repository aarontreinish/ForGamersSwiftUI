//
//  ContentView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/2/21.
//

import SwiftUI

struct LoginView: View {
    // MARK: - Propertiers
    @State private var email = ""
    @State private var password = ""
    
    @State var showsAlert = false
    
    @State var errorString = ""
    
    // MARK: - View
    var body: some View {
        VStack() {
            Text("iOS App Templates")
                .font(.largeTitle).foregroundColor(Color.white)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Email", text: self.$email)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                
                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding([.leading, .trailing], 27.5)
            
            Button(action: {
                AuthManager.shared.signIn(email: email, password: password) { (didSignIn, error) in
                    if let error = error {
                        self.showsAlert.toggle()
                        self.errorString = "\(error.localizedDescription)"
                    } else {
                        print(didSignIn)
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding(.top, 50)
            .alert(isPresented: self.$showsAlert) {
                Alert(
                    title: Text("Error logging in"),
                    message: Text("\(errorString)"),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Spacer()
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                Button(action: {}) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        
    }
}

extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
    }
}

struct ContentView: View {
    // MARK: - Propertiers
    @State private var email = ""
    @State private var password = ""
    
    @State var showsAlert = false
    @State var errorString = ""
    
    @State private var isPresented = false
    @State private var isSignUpViewPresented = false
    
    // MARK: - View
    var body: some View {
        VStack() {
            Text("For Gamers")
                .font(.largeTitle)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
            
            VStack(alignment: .leading, spacing: 15) {
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
            }.padding([.leading, .trailing], 27.5)
            
            Button(action: {
                AuthManager.shared.signIn(email: email, password: password) { (didSignIn, error) in
                    if let error = error {
                        self.showsAlert.toggle()
                        self.errorString = "\(error.localizedDescription)"
                    } else {
                        self.isPresented.toggle()
                        print(didSignIn)
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding(.top, 50)
            .fullScreenCover(isPresented: $isPresented, content: {
                TabBarView()
            })
            .alert(isPresented: self.$showsAlert) {
                Alert(
                    title: Text("Error logging in"),
                    message: Text("\(errorString)"),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Spacer()
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                Button(action: {
                    self.isSignUpViewPresented.toggle()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }.sheet(isPresented: $isSignUpViewPresented, content: {
                    SignUpView()
                })
            }
        }
//        .background(
//            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
