//
//  ChatRoom1.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

class ChatRoom1 {
    static let KEY_NAME = "name"
    static let KEY_BANNER = "banner"
    static let KEY_DESCRIPTION = "description"
    
    var guid: String!
    var name: String!
    var title: String!
    var createdAt: Double = 0
    var baner: String?
    
    convenience init(guid: String, obj: NSDictionary) {
        self.init()
        self.guid = guid
        if let banner = obj[ChatRoom1.KEY_BANNER] as? String {
            self.baner = banner
        }
        
        if let name = obj[ChatRoom1.KEY_NAME] as? String {
            self.name = name
        }
        
        if let title = obj[ChatRoom1.KEY_DESCRIPTION] as? String {
            self.title = title
        }
    }
    
    class func roomsWithArray(dicts: [String: AnyObject]) -> [ChatRoom1]{
        var rooms = [ChatRoom1]()
        for dict in dicts {
            print(dict)
            let room =  ChatRoom1(guid: dict.key, obj: dict.value as! NSDictionary)
            rooms.append(room)
        }
        return rooms
    }
}
