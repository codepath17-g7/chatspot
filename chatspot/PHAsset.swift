//
//  PHAsset.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/28/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    
    func getSmallImage(completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        manager.requestImage(for: self, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options, resultHandler: { (result: UIImage?, _) -> Void in
            if let image = result {
                completion(image)
            } else {
                completion(nil)
            }
        })
    }
    
    func getFullImage(completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = true // should this be true? maybe send it then update it later?
        
        //retrieve real image for that asset
        manager.requestImageData(for: self, options: options) { (data: Data?, _, _, _) in
            if let imageData = data {
                completion(UIImage(data: imageData))
            } else {
                completion(nil)
            }
        }
    }
    
}
