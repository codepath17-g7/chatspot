//
//  Message1.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Message1 {
    
    static let KEY_MESSAGE = "message"
    static let KEY_NAME = "name"
    static let KEY_TIMESTAMP = "timestamp"
    static let KEY_ROOM_ID = "roomId"
    
    var guid: String?
    var roomId: String?
    var message: String?
    var name: String?
    var timestamp: NSDate?
    
    convenience init(roomId: String, message: String, name: String) {
        self.init()
        self.roomId = roomId
        self.message = message
        self.name = name
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
            self.timestamp = NSDate(timeIntervalSince1970: epochTime)
        }
    }
    
    func toValue() -> NSDictionary {
        let value: NSDictionary = [
            Message1.KEY_MESSAGE: self.message ?? "",
            Message1.KEY_NAME: self.name ?? "Unknown",
            Message1.KEY_TIMESTAMP: ServerValue.timestamp()
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
