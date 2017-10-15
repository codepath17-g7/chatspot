//
//  User1.swift
//  chatspot
//
//  Created by Syed Hakeem Abbas on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

class User1 {
    static let KEY_DISPLAY_NAME = "name"
    static let KEY_PROFILE_IMAGE = "profileImageUrl"
    static let KEY_TAG_LINE = "tagline"
    static let KEY_BANNER_IMAGE = "bannerImageUrl"
    
    let createdAt: String? = ""
    
    var guid: String?
    var name: String?
    var tagline: String?
    var profileImage: String?
    var bannerImage: String?

    convenience init(guid: String, obj: [String: String]) {
        self.init()
        self.guid = guid
        if let name = obj[User1.KEY_DISPLAY_NAME] {
            self.name = name
        }
        if let profileImage = obj[User1.KEY_DISPLAY_NAME] {
            self.profileImage = profileImage
        }
    }
    
    
}
