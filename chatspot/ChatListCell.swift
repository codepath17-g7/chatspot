//
//  ChatListCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var viewOnMapButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
	var chatRoom: ChatRoom1! {
		didSet {
            
            chatRoomNameLabel.text = chatRoom.name
            if chatRoom.name == "Around Me" { //need better way to check if aroundme room
                self.locationLabel.isHidden = false
            }
            
            locationLabel.text = ""// set to location if Around Me
            memberCountLabel.text = String(describing: chatRoom.users?.count ?? 0)
			
            lastMessageLabel.text = chatRoom.lastMessage ?? "Say hi to the folks around you!"
            
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCountLabel.layer.cornerRadius = 12
        unreadCountLabel.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
