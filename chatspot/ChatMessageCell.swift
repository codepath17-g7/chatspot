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
    func sendPrivateMessageTo(user: User)
    func viewUserProfile(user: User)
}

class ChatMessageCell: UITableViewCell {
	
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var createdAtLabel: UILabel!
	@IBOutlet weak var messageTextLabel: UILabel!
	
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
            
		}
	}
	
    func handleUsernameTap(){
        print("Username tapped!")
        
        let alertController = UIAlertController(title: self.message.name!, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        let sendMessage = UIAlertAction(title: "Send Message", style: .default) { action in
            //self.delegate?.sendPrivateMessageTo(user: user)
            
        }

        let viewProfile = UIAlertAction(title: "View Profile", style: .default) { action in
                        //self.delegate?.viewUserProfile(user: user)
            
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
