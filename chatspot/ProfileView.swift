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
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userTaglineLabel: UILabel!
    
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
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(contentView)
    }
    
    func setupUserInfo(user: User1){
        self.user = user
        
        if let imgUrlStr = user.profileImage {
            profilePictureImageView.safeSetImageWith(urlStr: imgUrlStr)
        } else {
            profilePictureImageView.image = #imageLiteral(resourceName: "image-placeholder")
        }
        
        
        // User has a banner image
        if let bannerUrlStr = user.bannerImage {
            bannerImageView.safeSetImageWith(urlStr: bannerUrlStr)
            
        } else { // User doesn't have a banner image

            bannerImageView.image = nil
            
            // Pretty default gradient
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = headerView.frame
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.colors = [UIColor.ChatSpotColors.BrightPink.cgColor, UIColor.ChatSpotColors.PastelRed.cgColor]
            headerView.layer.insertSublayer(gradient, at: 0)
        }
        
        // Add semi-transparent gray layer // TODO: put this in the storyboard ProfileView.xib
        let grayOverlay = UIView(frame: bannerImageView.frame)
        grayOverlay.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        self.headerView.addSubview(grayOverlay)
        
        
        headerView.isUserInteractionEnabled = true
        bannerImageView.isUserInteractionEnabled = true
        
        usernameLabel.text = user.name
        if let tagline = user.tagline {
            userTaglineLabel.text = tagline
        }
        headerView.bringSubview(toFront: usernameLabel)
        headerView.bringSubview(toFront: userTaglineLabel)
        headerView.bringSubview(toFront: profilePictureImageView)
        layoutIfNeeded()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureImageView.layer.cornerRadius = 4
        profilePictureImageView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor.ChatSpotColors.LighterGray
        tableView.separatorColor = UIColor.ChatSpotColors.LightGray
        tableView.tableFooterView = UIView()
        
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

