//
//  Badge.swift
//  chatspot
//
//  Created by Eden on 11/8/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class Badge {
    var badgeType: BadgeType!
    var chatspotName: String!
    var badgeImage: UIImage!
    
    init(badgeType: BadgeType, chatspotName: String){
        self.badgeType = badgeType
        self.chatspotName = chatspotName
        self.badgeImage = badgeType.image
        
    }
}


enum BadgeType {
    case oneHundredMessagesSentInChannel
    // TODO: create more badges
//    case activityCreated
//    case thirtyChatspotsJoined
    
    var image: UIImage {
        switch self {
            case .oneHundredMessagesSentInChannel: return #imageLiteral(resourceName: "blueCap")
        default: return UIImage()
        }
    }
}
