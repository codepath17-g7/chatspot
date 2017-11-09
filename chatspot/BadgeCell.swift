//
//  BadgeCell.swift
//  chatspot
//
//  Created by Eden on 11/8/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class BadgeCell: UITableViewCell {

    @IBOutlet weak var badgeImageView: UIImageView!

    @IBOutlet weak var badgeInfoTextLabel: UILabel!
    
    var badge: Badge! {
        didSet {
            badgeImageView.image = badge.badgeImage
            badgeInfoTextLabel.text = badge.chatspotName
            if badge.chatspotName == "See All Badges" { // hacky. fix this (also in profileVC and chatroomdetailvc).
                self.badgeImageView.image = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
