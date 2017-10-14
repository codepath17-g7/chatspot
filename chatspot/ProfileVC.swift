//
//  ProfileVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var userView: UserView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let userWithImage = User()
        userWithImage.profileImage = "https://static.independent.co.uk/s3fs-public/thumbnails/image/2015/06/15/09/jon-snow.jpg"
        userWithImage.bannerImage = "https://i.ytimg.com/vi/uWmUdFIUtYs/maxresdefault.jpg"
        userWithImage.name = "John Snow"
        userWithImage.tagline = "Winter is coming"
        
        let userNoImage = User()
        userNoImage.name = "John Snow"
        userNoImage.tagline = "Winter is coming"
        
        userView.prepare(user: userNoImage, isSelf: true)
        
    }

}
