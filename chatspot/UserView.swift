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
    
    private var profileImageOriginalTransform: CGAffineTransform!
    private var profileImageOriginalCenter: CGPoint!
    
    
    private var isSelf: Bool!
    private var user: User!
    
    
    func prepare(user: User, isSelf: Bool) {
        self.user = user
        self.isSelf = isSelf
        
        if let imgUrlStr = user.profileImage {
            profileImage.setImageWith(URL(string: imgUrlStr)!)
        }
        
        if let bannerUrlStr = user.bannerImage {
            bannerImage.setImageWith(URL(string: bannerUrlStr)!)

        }
        
        userName.text = user.name
        
        if let tagline = user.tagline {
            userTagline.text = tagline
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 5
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.white.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        let nib = UINib(nibName: "UserView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }

    @IBAction func onBannerTapped(_ sender: Any) {
        print("Tapped banner")
    }
    
    @IBAction func onProfileImageTapped(_ sender: Any) {
        print("Tapped profile")
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = .photoLibrary
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let viewcon = appdelegate.window?.rootViewController
        
        viewcon?.present(vc, animated: true, completion: nil)
    }
    
    //MARK:- Gestures
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
            
            
            profileImage.center = CGPoint(x: profileImageOriginalCenter.x + translation.x * 2, y: profileImageOriginalCenter.y + translation.y / 2)
        } else if panGestureRecognizer.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                
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

extension UIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UserView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.image = originalImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
