//
//  User.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Realm
import RealmSwift

class User: Object { // Object is from Realm, this also extends a NSObject.
    
    @objc dynamic var guid: String!
    let createdAt = RealmOptional<Double>()
    
    @objc dynamic var name: String!
    @objc dynamic var tagline: String?
    @objc dynamic var profileImage: String?
    @objc dynamic var bannerImage: String?
    
    // linking between user and their messages.
    let messages = LinkingObjects(fromType: Message.self, property: "user")
    
    override static func primaryKey() -> String? {
        return "guid"
    }
    
    // our initializer with non-optional properties
    convenience init(guid: String, createdAt: Double, name: String) {
        self.init()
        self.guid = guid
        self.createdAt.value = createdAt
        self.name = name
    }
    
    // our initializer with all properties
    convenience init(guid: String, createdAt: Double, name: String,
                     tagline: String?, profileImage: String?, bannerImage: String?) {
        
        self.init(guid: guid, createdAt: createdAt, name: name)
        self.tagline = tagline
        self.profileImage = profileImage
        self.bannerImage = bannerImage
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
