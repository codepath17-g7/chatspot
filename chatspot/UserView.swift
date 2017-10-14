//
//  UserView.swift
//  chatspot
//
//  Created by Phuong Nguyen on 10/11/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import AFNetworking

class UserView: UIView {
    
    @IBOutlet fileprivate weak var profileImage: UIImageView!
    @IBOutlet fileprivate weak var bannerImage: UIImageView!
    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var userTagline: UILabel!
    
    @IBOutlet fileprivate var contentView: UIView!
    
    var user: User! {
        didSet {
            if let imgUrlStr = user.profileImage {
                profileImage.setImageWith(URL(string: imgUrlStr)!)
            }
            
            
        }
    }
    
    
    func prepare(user: User, isSelf: Bool) {
        self.user = user
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "UserView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    private var profileImageOriginalTransform: CGAffineTransform!
    private var profileImageOriginalCenter: CGPoint!
    
    @IBAction func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: contentView)
        let point = panGestureRecognizer.location(in: profileImage)
        
        
        print(point)
        print(translation)
        
        if panGestureRecognizer.state == .began {
            profileImageOriginalCenter = profileImage.center
            profileImageOriginalTransform = profileImage.transform
        } else if panGestureRecognizer.state == .changed {
            
            if (point.y > 150) {
                profileImage.transform = CGAffineTransform(rotationAngle: (-translation.x / 100 * 45).degreesToRadians)
            } else {
                profileImage.transform = CGAffineTransform(rotationAngle: (translation.x / 100 * 45).degreesToRadians)
            }
            
            
            profileImage.center = CGPoint(x: profileImageOriginalCenter.x + translation.x * 2, y: profileImageOriginalCenter.y)
        } else if panGestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: [], animations: {
                
                self.profileImage.center = self.profileImageOriginalCenter
                print("Move back")
                
                self.profileImage.transform = self.profileImageOriginalTransform
            })
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

