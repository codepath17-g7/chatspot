//
//  UserCell.swift
//  chatspot
//
//  Created by Varun Kochar on 10/22/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var user: User1! {
        didSet {
            
            profileImageView.cancelImageDownloadTask()
            if let urlString = user.profileImage {
                self.profileImageView.setImageWith(URL(string: urlString)!)
            }
            
            name.text = user.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 20
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
