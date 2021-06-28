//
//  ImagePicker.swift
//  ForGamersSwiftUI
//
//  Created by Aaron Treinish on 6/3/21.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
//struct ImagePicker: UIViewControllerRepresentable {
//    typealias UIViewControllerType = UIImagePickerController
//    typealias SourceType = UIImagePickerController.SourceType
//
//    let sourceType: SourceType
//    let completionHandler: (UIImage?) -> Void
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let viewController = UIImagePickerController()
//        viewController.delegate = context.coordinator
//        viewController.sourceType = sourceType
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(completionHandler: completionHandler)
//    }
//
//    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let completionHandler: (UIImage?) -> Void
//
//        init(completionHandler: @escaping (UIImage?) -> Void) {
//            self.completionHandler = completionHandler
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            let image: UIImage? = {
//                if let image = info[.editedImage] as? UIImage {
//                    return image
//                }
//                return info[.originalImage] as? UIImage
//            }()
//            completionHandler(image)
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            completionHandler(nil)
//        }
//    }
//}
