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
    
    
    @IBOutlet weak var bannerImage: UIImageWithEditView!
    @IBOutlet weak var profileImage: UIImageWithEditView!

    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var userNameField: UITextField!
    @IBOutlet fileprivate weak var userTagline: UILabel!
    @IBOutlet fileprivate weak var userTaglineField: UITextField!
    
    @IBOutlet fileprivate var contentView: UIView!
    
    private var profileImageOriginalTransform: CGAffineTransform!
    private var profileImageOriginalCenter: CGPoint!
    
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet fileprivate weak var editUserNameButton: UIButton!
    @IBOutlet fileprivate weak var editUserTaglineButton: UIButton!
    
    private var isSelf: Bool!
    private var user: User1!
    private var editMode: Bool = false
    private var editingUserName: Bool = false
    private var editingUserTagline: Bool = false

    fileprivate var imageToPick: ImageToPick?
    
    enum ImageToPick {
        case profile, banner
    }
    
    func prepare(user: User1, isSelf: Bool) {
        self.user = user
        self.isSelf = isSelf
        
        if let imgUrlStr = user.profileImage {
            profileImage.imageView.setImageWith(URL(string: imgUrlStr)!)
        } else {
            profileImage.imageView.image = #imageLiteral(resourceName: "ic_person")
        }
        
        if let bannerUrlStr = user.bannerImage {
            bannerImage.imageView.setImageWith(URL(string: bannerUrlStr)!)
        } else {
            bannerImage.imageView.image = #imageLiteral(resourceName: "ic_image")
        }
        
        userName.text = user.name
        userNameField.text = user.name
        
        if let tagline = user.tagline {
            userTagline.text = tagline
            userTaglineField.text = tagline
        }
        
        if isSelf {
            profileImage.showEditView()
            bannerImage.showEditView()
            
            
            sendMessageButton.isHidden = true
            editUserNameButton.isHidden = false
            editUserTaglineButton.isHidden = false
        } else {
            profileImage.hideEditView()
            bannerImage.hideEditView()

            sendMessageButton.isHidden = false
            editUserNameButton.isHidden = true
            editUserTaglineButton.isHidden = true
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 5
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        profileImage.onEditTapped = {
            print("Picking profile image")
            self.imageToPick = .profile
            self.pickImage()
        }
        bannerImage.onEditTapped = {
            print("Picking baner image")
            self.imageToPick = .banner
            self.pickImage()
        }
        
        contentView.bringSubview(toFront: userName)
        contentView.bringSubview(toFront: userTagline)
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

    func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
    private func pickImage() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = false
        vc.sourceType = .photoLibrary
        
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let topVc = topViewController(from: appdelegate.window?.rootViewController)
        topVc?.present(vc, animated: true, completion: nil)
    }

    
    func persistUserEdit() {
        ChatSpotClient.updateUserProfile(user: user)
    }
    
    //MARK:- Edit
    @IBAction func onEditUserName(_ sender: Any) {
        if !editingUserName {
            contentView.bringSubview(toFront: userNameField)
            userNameField.becomeFirstResponder()
        } else {
            userName.text = userNameField.text
            contentView.bringSubview(toFront: userName)
            user.name = userNameField.text
            persistUserEdit()
        }
        editingUserName = !editingUserName
    }
   
    @IBAction func onEditUserTagline(_ sender: Any) {
        if !editingUserTagline {
            contentView.bringSubview(toFront: userTaglineField)
            userTaglineField.becomeFirstResponder()
        } else {
            userTagline.text = userTaglineField.text
            contentView.bringSubview(toFront: userTagline)
            user.tagline = userTaglineField.text
            persistUserEdit()
        }
        editingUserTagline = !editingUserTagline
    }
    
    
    //MARK:- Gestures
    @IBAction func onPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: contentView)
        let point = panGestureRecognizer.location(in: profileImage)
        
//        print(point)
//        print(translation)
        
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
        picker.dismiss(animated: true, completion: nil)

        switch imageToPick! {
        case .profile:
            profileImage.imageView.image = originalImage

            break
        case .banner:
            bannerImage.imageView.image = originalImage
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
