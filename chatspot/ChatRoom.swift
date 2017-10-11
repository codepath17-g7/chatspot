//
//  ChatRoom.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

class ChatRoom: NSObject {
    var guid: String!
    var name: String!
    var createdAt: Date!
    
    var longitude: Double!
    var latitude: Double!
    
    var userCount: Int!
    var roomBanner: String?
    var roomActivity: Int!
}
