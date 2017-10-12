//
//  ChatRoom.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

@objcMembers class ChatRoom: Object { // Object is from Realm, this also extends a NSObject.
    
    dynamic var guid: String!
    dynamic var name: String!
    dynamic var createdAt: Date!
    
    dynamic var longitude: Double!
    dynamic var latitude: Double!
    
    dynamic var userCount: Int!
    dynamic var roomBanner: String?
    dynamic var roomActivity: Int!
    
    // linking between a chat room and all of its messages
    let messages = LinkingObjects(fromType: Message.self, property: "chatRoom")
    
    override static func primaryKey() -> String? {
        return "guid"
    }
}
