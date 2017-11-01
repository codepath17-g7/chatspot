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
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var peopleIconImageView: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    

    @IBOutlet weak var accountImageToAroundMeConstraint: NSLayoutConstraint!
    
    @IBOutlet var acountImageToLocationConstraint: NSLayoutConstraint!
    
    var unreadCount: Int = 0 {
        didSet {
            unreadCountLabel.isHidden = (unreadCount == 0)
            unreadCountLabel.text = "\(unreadCount)"
        }
    }
    
	var chatRoom: ChatRoom1! {
		didSet {
            
            peopleIconImageView.changeToColor(color: .darkGray)
            chatRoomNameLabel.text = chatRoom.name
            if chatRoom.isAroundMe {
                if let currentLocationName = ChatSpotClient.chatrooms[chatRoom.guid]?.name {
                    locationLabel.text = "at \(currentLocationName)"
                    accountImageToAroundMeConstraint.constant = 16 + locationLabel.frame.width
                    acountImageToLocationConstraint.isActive = true
                    locationLabel.isHidden = false
                }
            } else {
                accountImageToAroundMeConstraint.constant = 8
                acountImageToLocationConstraint.isActive = false
                locationLabel.isHidden = true
            }
            
            if (chatRoom.isAroundMe) {
                memberCountLabel.text = String(describing: chatRoom.localUsers?.count ?? 0)
            } else {
                memberCountLabel.text = String(describing: chatRoom.users?.count ?? 0)
            }
			
            lastMessageLabel.text = chatRoom.lastMessage
            
            self.updateConstraints()
            
            if let bannerString = chatRoom.banner {
                guard let url = URL(string: bannerString) else { return }
                chatRoomImageView.hnk_setImageFromURL(url)
            } else if chatRoom.isAroundMe {
                if let bannerString = ChatSpotClient.chatrooms[chatRoom.guid]?.banner {
                    guard let url = URL(string: bannerString) else { return }
                    chatRoomImageView.hnk_setImageFromURL(url)
                }
            } else {
                chatRoomImageView.image = #imageLiteral(resourceName: "24hourfitlong")
            }
            
            
            // if cell above you is from same author as you, hide your profile pic and author label. edit constraints of author label
            
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCountLabel.layer.cornerRadius = 12
        unreadCountLabel.layer.masksToBounds = true

        cardView.layer.shadowRadius = 3.0
        
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: cardView.frame.size.width + shadowSize,
                                              height: cardView.frame.size.height + shadowSize))
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowPath = shadowPath.cgPath
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
