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
    static let KEY_LATITUDE = "latitude"
    static let KEY_LONGITUDE = "longitude"
    static let KEY_USERS = "users"
    static let KEY_LOCAL_USERS = "localUsers"
    static let KEY_LAST_MESSAGE = "lastMessage"
    static let KEY_LAST_MESSAGE_TIMESTAMP = "lastMessageTimestamp"
    
    var guid: String!
    var name: String!
    var title: String!
    var createdAt: Double = 0
    var baner: String?
    var longitude: Double!
    var latitude: Double!
    var users: [String:Bool]? // these users joined the room manually
    var localUsers: [String:Bool]? // these users auto joined the room
    var lastMessage: String = ""
    var lastMessageTimestamp: Double = 0
    
    // for use on client side only, don't send to server
    var isAroundMe: Bool = false
    
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
        
        if let longitude = obj[ChatRoom1.KEY_LONGITUDE] as? String {
            self.longitude = Double.init(longitude)
        }
        
        if let latitude = obj[ChatRoom1.KEY_LATITUDE] as? String {
            self.latitude = Double.init(latitude)
        }
        
        if let users = obj[ChatRoom1.KEY_USERS] as? [String:Bool] {
            self.users = users
        }
        
        if let localUsers = obj[ChatRoom1.KEY_LOCAL_USERS] as? [String:Bool] {
            self.localUsers = localUsers
        }
        
        if let lastMessage = obj[ChatRoom1.KEY_LAST_MESSAGE] as? String {
            self.lastMessage = lastMessage
        }
        
        if let lastMessageTimestamp = obj[ChatRoom1.KEY_LAST_MESSAGE_TIMESTAMP] as? Double {
            self.lastMessageTimestamp = lastMessageTimestamp
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
