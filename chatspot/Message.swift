//
//  Message.swift
//  chatspot
//
//  Created by Eden on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

class Message: Object { // Object is from Realm, this also extends a NSObject.
    
	@objc dynamic var guid: String!
    @objc dynamic var createdAt: Date!
	@objc dynamic var image: String?
	@objc dynamic var message: String?
    
    // linked items
    @objc dynamic var user: User?
    @objc dynamic var chatRoom: ChatRoom?
    
    override static func primaryKey() -> String? {
        return "guid"
    }
    
	// define later
	// Reaction
}
