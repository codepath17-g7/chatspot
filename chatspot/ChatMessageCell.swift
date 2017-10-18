//
//  ChatMessageCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo

@objc protocol ChatMessageCellDelegate {
    func presentAlertViewController(alertController: UIAlertController)
    func sendPrivateMessageTo(userID: String)
    func viewUserProfile(userID: String)
}

class ChatMessageCell: UITableViewCell {
	
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var createdAtLabel: UILabel!
	@IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var authorProfileImage: UIImageView!
    
    
    weak var delegate: ChatMessageCellDelegate?
    
	var message: Message1! {
		didSet {
			if let author = message.name {
				authorLabel.text = author
			}
			if let text = message.message {
				messageTextLabel.text = text
			}
            
            if message.timestamp?.timeAgo() == "0 s" {
                createdAtLabel.text = "Now"
            } else {
                createdAtLabel.text = message.timestamp?.timeAgo()
            }
            if let guid = message.userGuid {
                setUpUserInfo(userGuid: guid)

            }
		}
	}
    
    func setUpUserInfo(userGuid: String){
        self.authorProfileImage.clipsToBounds = true
        self.authorProfileImage.layer.cornerRadius = 7
        self.authorProfileImage.changeToColor(color: .darkGray)
        ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user: User1) in
            //self.user = user
            if let urlString = user.profileImage {
                self.authorProfileImage.setImageWith(URL(string: urlString)!)
            }
        }, failure: {
            print("Failure to find user")
        })
    }
    
	
    func handleUsernameTap(){
        print("Username tapped!")
        
        let alertController = UIAlertController(title: self.message.name, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        let sendMessage = UIAlertAction(title: "Send Message", style: .default) { action in
            self.delegate?.sendPrivateMessageTo(userID: self.message.userGuid)
            
        }

        let viewProfile = UIAlertAction(title: "View Profile", style: .default) { action in
            self.delegate?.viewUserProfile(userID: self.message.userGuid)
            
        }
        alertController.addAction(sendMessage)
        alertController.addAction(viewProfile)
        self.delegate?.presentAlertViewController(alertController: alertController)

    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // add tap gesture to authorLabel
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTap))
        authorLabel.addGestureRecognizer(tapGesture)
        authorLabel.isUserInteractionEnabled = true
        tapGesture.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
