//
//  Message.swift
//  chatspot
//
//  Created by Eden on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Realm
import RealmSwift

class Message: Object { // Object is from Realm, this also extends a NSObject.
    
    @objc dynamic var guid: String!
    @objc dynamic var createdAt: Double = 0
    @objc dynamic var image: String?
    @objc dynamic var message: String?
    
    // linked items
    @objc dynamic var user: User?
    @objc dynamic var chatRoom: ChatRoom?
    
    override static func primaryKey() -> String? {
        return "guid"
    }
    
    // our initializer with non-optional properties
    convenience init(guid: String, createdAt: Double) {
        self.init()
        self.guid = guid
        self.createdAt = createdAt
    }
    
    // our initializer with all properties
    convenience init(guid: String, createdAt: Double,
                     image: String?, message: String?, user: User?, chatRoom: ChatRoom?) {
        
        self.init(guid: guid, createdAt: createdAt)
        self.image = image
        self.message = message
        self.user = user
        self.chatRoom = chatRoom
    }
    
    // The required initializers
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    
    // define later
    // Reaction
}
