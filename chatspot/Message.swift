//
//  Message.swift
//  chatspot
//
//  Created by Eden on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

@objcMembers class Message: Object { // Object is from Realm, this also extends a NSObject.
    
	dynamic var guid: String!
    dynamic var createdAt: Date!
	dynamic var image: String?
	dynamic var message: String?
    
    // linked items
    dynamic var user: User?
    dynamic var chatRoom: ChatRoom?
    
    override static func primaryKey() -> String? {
        return "guid"
    }
    
	// define later
	// Reaction
}
