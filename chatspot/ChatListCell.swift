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
    @IBOutlet weak var chatRoomImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var viewOnMapButton: UIButton!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    
    var unreadCount: Int = 0 {
        didSet {
            unreadCountLabel.isHidden = (unreadCount == 0)
            unreadCountLabel.text = "\(unreadCount)"
        }
    }
    
	var chatRoom: ChatRoom1! {
		didSet {
            
            chatRoomNameLabel.text = chatRoom.name
            
            ////////// change back later //////////
            self.locationLabel.isHidden = false
            locationLabel.text = "Oakland, CA"
            if chatRoom.name == "Golden Gate Bridge"{
                chatRoomImageView.image = #imageLiteral(resourceName: "goldengate")
            } else {
                chatRoomImageView.image = #imageLiteral(resourceName: "24hourfitlong")
            }
            //////////////////////////////////////////////

            if chatRoom.isAroundMe {
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
        
        cardView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cardView.layer.shadowRadius = 3.0
        cardView.layer.shadowOpacity = 0.6
        cardView.layer.masksToBounds = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
