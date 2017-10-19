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
    static let KEY_AROUND_ME = "aroundMe"

    let createdAt: String? = ""
    
    var guid: String?
    var name: String?
    var tagline: String?
    var profileImage: String?
    var bannerImage: String?
    var aroundMe: String?

    convenience init(guid: String, obj: NSDictionary) {
        self.init()
        self.guid = guid
        if let name = obj[User1.KEY_DISPLAY_NAME] as? String {
            self.name = name
        }
        
        if let profileImage = obj[User1.KEY_PROFILE_IMAGE] as? String {
            self.profileImage = profileImage
        }
        
        if let bannerImage = obj[User1.KEY_BANNER_IMAGE] as? String {
            self.bannerImage = bannerImage
        }
        
        if let tagline = obj[User1.KEY_TAG_LINE] as? String {
            self.tagline = tagline
        }
        
        if let aroundMe = obj[User1.KEY_AROUND_ME] as? String {
            self.aroundMe = aroundMe
        }
    }
    
    class func usersWithArray(dicts: [String: AnyObject]) -> [User1]{
        var users = [User1]()
        for dict in dicts {
            print(dict)
            let user =  User1(guid: dict.key, obj: dict.value as! NSDictionary)
            users.append(user)
        }
        return users
    }
}
