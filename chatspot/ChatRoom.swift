//
//  ChatRoom.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Realm
import RealmSwift

class ChatRoom: Object { // Object is from Realm, this also extends a NSObject.
    
    @objc dynamic var guid: String!
    @objc dynamic var name: String!
    @objc dynamic var createdAt: Double = 0
    @objc dynamic var roomBanner: String?
    
    let longitude = RealmOptional<Double>() // primitive types can be made optional in realm by using a `RealmOptional`
    let latitude = RealmOptional<Double>()
    let userCount = RealmOptional<Int>()
    let roomActivity = RealmOptional<Int>()
    
    let users = List<User>()
    
    // linking between a chat room and all of its messages
    let messages = LinkingObjects(fromType: Message.self, property: "chatRoom")
    
    override static func primaryKey() -> String? {
        return "guid"
    }
    
    // our initializer with non-optional properties
    convenience init(guid: String, createdAt: Double, name: String) {
        self.init()
        self.guid = guid
        self.createdAt = createdAt
        self.name = name
    }
    
    // our initializer with all properties
    convenience init(guid: String, createdAt: Double, name: String,
                     roomBanner: String?, latitude: Double?, longitude: Double?, userCount: Int?, roomActivity: Int?) {
        
        self.init(guid: guid, createdAt: createdAt, name: name)
        self.roomBanner = roomBanner
        self.latitude.value = latitude
        self.longitude.value = longitude
        self.userCount.value = userCount
        self.roomActivity.value = roomActivity
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
}
