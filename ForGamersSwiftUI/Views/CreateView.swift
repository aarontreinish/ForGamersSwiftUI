//
//  CreateView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/7/21.
//

import SwiftUI

struct CreateView: View {
    @State private var text = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: self.$text)
                .padding()
                .cornerRadius(20.0)
                .shadow(radius: 10.0, x: 20, y: 10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
