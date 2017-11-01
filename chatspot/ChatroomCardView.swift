//
//  ChatroomCardView.swift
//  chatspot
//
//  Created by Eden on 10/31/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import Haneke
import FirebaseAuthUI

class ChatroomCardView: UIView {

    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var chatRoomImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var peopleIconImageView: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var accountImageToAroundMeConstraint: NSLayoutConstraint!
    
    @IBOutlet var acountImageToLocationConstraint: NSLayoutConstraint!

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
            
            if chatRoom.users?.index(forKey: ChatSpotClient.userGuid) != nil {
                joinButton.isHidden = true
            } else {
                joinButton.isHidden = false
            }
            
            
        }
    }
    
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
    
    func loadFromXib() {

        // standard initialization logic
        Bundle.main.loadNibNamed("ChatroomCardView", owner: self, options: nil)
        contentView!.frame = bounds
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView!)
        
        cardView.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        cardView.layer.shadowRadius = 3.0
        cardView.layer.shadowOpacity = 0.6
        cardView.layer.masksToBounds = false
        
        joinButton.setRadiusWithShadow()
        
    }
    
    @IBAction func joinButtonClicked(_ sender: Any) {
        print("joining room \(chatRoom.guid)")
        let user = Auth.auth().currentUser!
        ChatSpotClient.joinChatRoom(userGuid: user.uid, roomGuid: chatRoom.guid)
        joinButton.setImage(#imageLiteral(resourceName: "blue check button"), for: .selected)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.joinButton.isSelected = true
        }
    }
    

    

}
