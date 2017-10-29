//
//  Message1.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Photos

class Message1 {
    
    static let KEY_MESSAGE = "message"
    static let KEY_NAME = "name"
    static let KEY_USER_GUID = "userGuid"
    static let KEY_TIMESTAMP = "timestamp"
    static let KEY_ROOM_ID = "roomId"
    static let KEY_ATTACHMENT = "attachment"
    static let KEY_SYSTEM = "system"
    static let KEY_MEDIA_URL = "mediaFileUrl"
    static let KEY_MEDIA_TYPE = "mediaType"
    static let KEY_THUMB_URL = "thumbnailImageUrl"

    var guid: String?
    var roomId: String?
    var message: String?
    var name: String?
    var timestamp: NSDate?
    var userGuid: String!
    var attachment: String?
    var mediaFileUrl: String?
    var mediaType: Int?
    var thumbnailImageUrl: String?
    var rawTimestamp: Double = NSDate().timeIntervalSince1970
    var system = false // indicate a system message (no user node)


    convenience init(roomId: String, message: String, name: String, userGuid: String, attachment: String?) {
        self.init()
        self.roomId = roomId
        self.message = message
        self.name = name
        self.userGuid = userGuid
        self.attachment = attachment
        self.rawTimestamp = NSDate().timeIntervalSince1970
    }

    convenience init(roomId: String, message: String, name: String, userGuid: String) {
        self.init(roomId: roomId, message: message, name: name, userGuid: userGuid, attachment: nil)
        self.rawTimestamp = NSDate().timeIntervalSince1970
    }
    
    convenience init(guid: String, obj: NSDictionary) {
        self.init()
        
        self.guid = guid
        
        if let roomId = obj[Message1.KEY_ROOM_ID] as? String {
            self.roomId = roomId
        }
        
        if let message = obj[Message1.KEY_MESSAGE] as? String{
            self.message = message
        }
        
        if let name = obj[Message1.KEY_NAME] as? String{
            self.name = name
        }
    
        if let timestamp = obj[Message1.KEY_TIMESTAMP] as? Double {
            let epochTime = TimeInterval(timestamp)/1000
            self.rawTimestamp = epochTime
            self.timestamp = NSDate(timeIntervalSince1970: epochTime)
        }
        
        if let userGuid = obj[Message1.KEY_USER_GUID] as? String {
            self.userGuid = userGuid
        }
        
        if let attachment = obj[Message1.KEY_ATTACHMENT] as? String {
            self.attachment = attachment
        }
        
        if let mediaType = obj[Message1.KEY_MEDIA_TYPE] as? Int {
            self.mediaType = mediaType
        }
        
        if let mediaFileUrl = obj[Message1.KEY_MEDIA_URL] as? String {
            self.mediaFileUrl = mediaFileUrl
            // if no media type defined, default to image
            if self.mediaType == nil {
                self.mediaType = PHAssetMediaType.image.rawValue
            }
        }

        if let thumbnailImageUrl = obj[Message1.KEY_THUMB_URL] as? String {
            self.thumbnailImageUrl = thumbnailImageUrl
        }
        
        if let system = obj[Message1.KEY_SYSTEM] as? Bool {
            self.system = system
        }
        
        
    }
    
    func toValue() -> NSDictionary {
        let value: NSDictionary = [
            Message1.KEY_MESSAGE: self.message ?? "",
            Message1.KEY_NAME: self.name ?? "Unknown",
            Message1.KEY_TIMESTAMP: ServerValue.timestamp(),
            Message1.KEY_USER_GUID: self.userGuid,
            Message1.KEY_ATTACHMENT: self.attachment ?? "",
            Message1.KEY_MEDIA_URL: self.mediaFileUrl ?? "",
            Message1.KEY_THUMB_URL: self.thumbnailImageUrl ?? "",
            Message1.KEY_MEDIA_TYPE: self.mediaType,
            Message1.KEY_SYSTEM: self.system
        ]
        
        return value
    }
    
    class func messagesWithArray(dicts: [String: AnyObject]) -> [Message1]{
        var messages = [Message1]()
        for dict in dicts {
            print(dict)
            let message =  Message1(guid: dict.key, obj: dict.value as! NSDictionary)
            messages.append(message)
        }
        return messages
    }
}
