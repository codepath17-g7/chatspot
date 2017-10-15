//
//  ChatMessageCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo

class ChatMessageCell: UITableViewCell {
	
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var createdAtLabel: UILabel!
	@IBOutlet weak var messageTextLabel: UILabel!
	
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
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
