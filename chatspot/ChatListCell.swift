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
            locationLabel.isHidden = true
            if chatRoom.isAroundMe {
                if let currentLocationName = ChatSpotClient.chatrooms[chatRoom.guid]?.name {
                    locationLabel.text = currentLocationName
                    locationLabel.isHidden = false
                }
            }
            
            
            ////////// Hardcoded Data //////////
            switch chatRoom.name {
            case "Golden Gate Bridge":
                chatRoomImageView.image = #imageLiteral(resourceName: "goldengate")
//            case "Rengstorff Park":
            
            case "Around Me":
                chatRoomImageView.image = #imageLiteral(resourceName: "24hourfitlong")
            default:
                chatRoomImageView.image = #imageLiteral(resourceName: "24hourfitlong")
            }
            
            //////////////////////////////////////////////

            // if cell above you is from same author as you, hide your profile pic and author label. edit constraints of author label
            
            
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
