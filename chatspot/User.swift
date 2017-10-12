//
//  User.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

@objcMembers class User: Object { // Object is from Realm, this also extends a NSObject.
    
    dynamic var guid: String!
    dynamic var createdAt: Date!

    dynamic var name: String!
    dynamic var tagline: String?
    dynamic var profileImage: String?
    dynamic var bannerImage: String?
    
    // linking between user and their messages.
    let messages = LinkingObjects(fromType: Message.self, property: "user")
    
    override static func primaryKey() -> String? {
        return "guid"
    }

}
