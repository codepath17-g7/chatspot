//
//  StorageClient.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/20/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageClient: NSObject {
    static let instance = StorageClient()
    
    var storage :FirebaseStorage.Storage!
    var storageRef :StorageReference!
    
    override init() {
        storage = FirebaseStorage.Storage.storage()
        storageRef = storage.reference()

    }
    
    
    func storeImage(ref :StorageReference, image: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let data = UIImagePNGRepresentation(image)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        ref.putData(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                failure()
                return
            }

            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL()
            success(downloadURL)
        }
    }
    
    func resizeImage(image: UIImage, width: Int, height: Int) -> UIImage? {
        let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = .scaleAspectFill
        resizeRenderImageView.image = image
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func storeProfileImage(userGuid: String, profileImage: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let imagesRef = storageRef.child("userProfile").child(userGuid+".png")

        let resizedImage = resizeImage(image: profileImage, width: 175, height: 175)
        storeImage(ref: imagesRef, image: resizedImage!, success: success, failure: failure)
    }
    
    func storeBannerImage(userGuid: String, bannerImage: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let imagesRef = storageRef.child("userBanner").child(userGuid+".png")
        
        let resizedImage = resizeImage(image: bannerImage, width: 375, height: 196)
        storeImage(ref: imagesRef, image: resizedImage!, success: success, failure: failure)
    }
    
    func storeChatImage(userGuid: String, chatImage: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let imagesRef = storageRef.child("chatImage").child(userGuid+".png")
        
        // what size should this be?
        let resizedImage = resizeImage(image: chatImage, width: 375, height: 600)
        storeImage(ref: imagesRef, image: resizedImage!, success: success, failure: failure)
    }
    
    
}
