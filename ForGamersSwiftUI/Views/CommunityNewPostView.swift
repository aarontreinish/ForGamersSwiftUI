//
//  CommunityNewPostView.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/3/21.
//

import SwiftUI

struct CommunityNewPostView: View {
    @State private var message = "Write your post here..."
    @State private var textStyle = UIFont.TextStyle.body
    let community: Community
    @State private var isVideo = false
    @State private var isShowPhotoLibrary = false
    @State private var image: UIImage?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Spacer()
                Button("Submit") {
                    FirestoreManager.shared.submitPost(community: community, postText: message, selectedImage: image, mediaURL: URL(string: ""), isVideo: isVideo) { (didPost) in
                        if didPost == true {
                            print("POSTED")
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            print("Failed to post")
                        }
                    }
                }.padding()
            }
            Spacer()
            
            TextView(text: $message, textStyle: $textStyle)
                .padding(.horizontal)
            
            Image(uiImage: self.image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300, alignment: .center)
            
            Button(action: {
                self.isShowPhotoLibrary = true
            }) {
                HStack {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    
                    Text("Photo library")
                        .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
            
            //Spacer()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
    }
}

struct CommunityNewPostView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityNewPostView(community: Community(communityName: "", communityImageURL: ""))
    }
}

//extension NewPostView {
//    final class ViewModel: ObservableObject {
//        @Published var selectedImage: UIImage?
//        @Published var isPresentingImagePicker = false
//        private(set) var sourceType: ImagePicker.SourceType = .camera
//
//        func choosePhoto() {
//            sourceType = .photoLibrary
//            isPresentingImagePicker = true
//        }
//
//        func takePhoto() {
//            sourceType = .camera
//            isPresentingImagePicker = true
//        }
//
//        func didSelectImage(_ image: UIImage?) {
//            selectedImage = image
//            isPresentingImagePicker = false
//        }
//    }
//}
