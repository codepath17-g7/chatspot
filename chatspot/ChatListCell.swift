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
    
	var chatRoom: ChatRoom! {
		didSet {
            
            chatRoomNameLabel.text = chatRoom.name // do special things if "around me" chat
            
            locationLabel.text = ""// set to location if Around Me
            memberCountLabel.text = "25" // set to actual member count
			
            lastMessageLabel.text = "anyone up for some pickup soccer?"
			
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
