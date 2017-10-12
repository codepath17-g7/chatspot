//
//  User.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import RealmSwift

class User: Object { // Object is from Realm, this also extends a NSObject.
    
    @objc dynamic var guid: String!
    @objc dynamic var createdAt: Date!

    @objc dynamic var name: String!
    @objc dynamic var tagline: String?
    @objc dynamic var profileImage: String?
    @objc dynamic var bannerImage: String?
    
    // linking between user and their messages.
    let messages = LinkingObjects(fromType: Message.self, property: "user")
    
    override static func primaryKey() -> String? {
        return "guid"
    }

}
