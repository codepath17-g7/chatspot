//
//  ChatMessageCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
	
	
	var message: Message! {
		didSet {
			//set sender name
			//set message text 
			//set message time
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