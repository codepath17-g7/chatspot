//
//  User.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation

class User: NSObject {
    var guid: String!
    var createdAt: Date!

    var name: String!
    var tagline: String?
    var profileImage: String?
    var bannerImage: String?
}
