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
    static let KEY_UNREAD_COUNT = "unreadMessageCount"
    static let KEY_LEVEL = "level"

    let createdAt: String? = ""
    
    var guid: String?
    var name: String?
    var tagline: String?
    var profileImage: String?
    var bannerImage: String?
    var aroundMe: String?
    var unreadMessageCount: [String: Int]?
    var level: Int = 0

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
        
        if let unreadMessageCount = obj[User1.KEY_UNREAD_COUNT] as? [String: Int] {
            self.unreadMessageCount = unreadMessageCount
        }
        
        if let level = obj[User1.KEY_LEVEL] as? String {
            self.level = Int(level)!
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
    
    func toValue() -> [String: String] {
        return [
            User1.KEY_DISPLAY_NAME: self.name ?? "",
            User1.KEY_PROFILE_IMAGE: self.profileImage ?? "",
            User1.KEY_BANNER_IMAGE: self.bannerImage ?? "",
            User1.KEY_TAG_LINE: self.tagline ?? "",
            User1.KEY_LEVEL: self.level.description,
            ]
    }
}
