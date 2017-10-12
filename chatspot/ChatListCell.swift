//
//  ChatListCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
	
	var chatRoom: ChatRoom! {
		didSet {
			//set chat name
			//set chat current members number (optional, because of PMs)
			//set other things
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
