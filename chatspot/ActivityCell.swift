//
//  ActivityCell.swift
//  chatspot
//
//  Created by Varun on 10/31/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var action: ((Bool, String)->())?
    
    var activity: Activity! {
        
        didSet {
            
            let timeAgo = Date().ago(pastDate: activity.createdAt)
            timeAgoLabel.text = timeAgo
            
            activityName.text = activity.activityName
            
            let currentUserGuid = ChatSpotClient.currentUser.guid
            
            actionButton.isSelected = activity
                .usersJoined
                .contains(where: { (k, v) -> Bool in
                    return k == currentUserGuid
                })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        actionButton.imageView?.contentMode = .scaleAspectFit
        actionButton.setImage(#imageLiteral(resourceName: "plusButton"), for: .normal)
        actionButton.setImage(#imageLiteral(resourceName: "checkButton"), for: .selected)
    }
    
    @IBAction func onTapAction(_ sender: Any) {
        actionButton.isSelected = !actionButton.isSelected
        action?(actionButton.isSelected, activity.guid!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
