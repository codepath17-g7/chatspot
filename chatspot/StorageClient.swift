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
//        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
//        resizeRenderImageView.layer.borderWidth = 3.0
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
    
    func storeChatroomBannerImage(chatRoomGuid: String, bannerImage: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let imagesRef = storageRef.child("chatRoomBanners").child(chatRoomGuid+".png")
        storeImage(ref: imagesRef, image: bannerImage, success: success, failure: failure)
    }
    
    
    func storeChatImage(chatImage: UIImage, success: @escaping (URL?, URL?) -> (), failure: @escaping () -> ()) {
        
        let imageUUID = NSUUID().uuidString
        let thumbNailRef = storageRef.child("chatImage").child(imageUUID+"_thumb.png")
        let imagesRef = storageRef.child("chatImage").child(imageUUID+".png")
        
        // what size should this be?
        let thumbNailImage = resizeImage(image: chatImage, width: 200, height: 200)
        let resizedImage = resizeImage(image: chatImage, width: 375, height: 600)

        var thumbNailUrl: URL?
        var fullSizeUrl: URL?

        let taskGroup = DispatchGroup()
        
        taskGroup.enter()
        storeImage(ref: thumbNailRef, image: thumbNailImage!, success: { (returnUrl: URL?) in
            thumbNailUrl = returnUrl
            taskGroup.leave()
        }) { 
            taskGroup.leave()
        }
        
        taskGroup.enter()
        storeImage(ref: imagesRef, image: resizedImage!, success: { (returnUrl: URL?) in
            fullSizeUrl = returnUrl
            taskGroup.leave()
        }) {
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            success(thumbNailUrl, fullSizeUrl)
        }))
    }
    
    func storeRegularImage(chatImage: UIImage, success: @escaping (URL?) -> (), failure: @escaping () -> ()){
        let imageUUID = NSUUID().uuidString
        let imagesRef = storageRef.child("chatImage").child(imageUUID+".png")
        storeImage(ref: imagesRef, image: chatImage, success: { (returnUrl: URL?) in
            success(returnUrl)
        }, failure: {() in
            failure()
        })
    }
    
    
    func storeChatImage(chatImage: UIImage, width: Int, height: Int, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let imageUUID = NSUUID().uuidString
        let imagesRef = storageRef.child("chatImage").child(imageUUID+".png")
        let resizedImage = resizeImage(image: chatImage, width: width, height: height)
        storeImage(ref: imagesRef, image: resizedImage!, success: success, failure: failure)
    }   
        
    func storeChatVideo(videoUrl: URL, success: @escaping (URL?) -> (), failure: @escaping () -> ()) {
        let videoRef = storageRef.child("chatVideo").child(NSUUID().uuidString+".mov")
        
        videoRef.putFile(from: videoUrl, metadata: nil) { (metadata: StorageMetadata?, error: Error?) in
            if error == nil {
                success(metadata?.downloadURL())
            } else {
                failure()
            }
        }
    }
}
