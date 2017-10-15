//
//  Message1.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

class Message1 {
    
    static let KEY_MESSAGE = "message"
    static let KEY_NAME = "name"
    static let KEY_TIMESTAMP = "timestamp"
    
    var guid: String?
    var message: String?
    var name: String?
    var timestamp: Int?
    
    convenience init(guid: String, obj: NSDictionary) {
        self.init()
        
        self.guid = guid
        
        if let message = obj[Message1.KEY_MESSAGE] as? String{
            self.message = message
        }
        
        if let name = obj[Message1.KEY_NAME] as? String{
            self.name = name
        }
        
        if let timestamp = obj[Message1.KEY_TIMESTAMP] as? Int {
            self.timestamp = timestamp
        }
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
