//
//  ProfileView.swift
//  chatspot
//
//  Created by Eden on 11/8/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    @IBOutlet fileprivate var contentView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var bannerImageView: UIImageView!
    @IBOutlet fileprivate weak var profilePictureImageView: UIImageView!
    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var userTaglineLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    fileprivate var user: User1!
    private var profileImageOriginalTransform: CGAffineTransform!
    private var profileImageOriginalCenter: CGPoint!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "ProfileView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    func setupUserInfo(user: User1){
        self.user = user
        
        if let imgUrlStr = user.profileImage {
            profilePictureImageView.safeSetImageWith(urlStr: imgUrlStr)
        } else {
            profilePictureImageView.image = #imageLiteral(resourceName: "image-placeholder")
        }
        
        
        if let bannerUrlStr = user.bannerImage {
            bannerImageView.safeSetImageWith(urlStr: bannerUrlStr)
        } else {
        // TODO: change to pretty gradient
            bannerImageView.image = #imageLiteral(resourceName: "image-placeholder")
        }
        
        usernameLabel.text = user.name
        
        if let tagline = user.tagline {
            userTaglineLabel.text = tagline
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureImageView.layer.cornerRadius = 7
        profilePictureImageView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        tableView.separatorStyle = .none

    }

}

extension UIImageView {
    open func safeSetImageWith(urlStr: String?) {
        guard let urlStr = urlStr else {
            return
        }
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        setImageWith(url)
    }
    
}


//        if isSelf {
////            profileImage.showEditView()
////            bannerImage.showEditView()
////
////
////            sendMessageButton.isHidden = true
////            editUserNameButton.isHidden = false
////            editUserTaglineButton.isHidden = false
//        } else {
////            profileImage.hideEditView()
////            bannerImage.hideEditView()
////
////            sendMessageButton.isHidden = false
////            editUserNameButton.isHidden = true
////            editUserTaglineButton.isHidden = true
//        }

//        profilePictureImageView.layer.borderWidth = 5
//        profilePictureImageView.layer.borderColor = UIColor.white.cgColor
