//
//  ChatMessageCell.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import NSDateMinimalTimeAgo
import Haneke

@objc protocol ChatMessageCellDelegate {
    func presentAlertViewController(alertController: UIAlertController)
    func sendPrivateMessageTo(userID: String)
    func viewUserProfile(userID: String)
}

class ChatMessageCell: UITableViewCell {
	
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var createdAtLabel: UILabel!
	@IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var authorProfileImage: UIImageView!
    @IBOutlet weak var authorLevelImage: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    
    @IBOutlet var messageImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var messageImageBottomConstraint: NSLayoutConstraint!
    
    let imageCache = Shared.imageCache
    weak var delegate: ChatMessageCellDelegate?
    
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
            if let guid = message.userGuid {
                setUpUserInfo(userGuid: guid)

            }
            
            messageTextLabel.isHidden = false
            messageImageView.isHidden = true
            messageImageHeightConstraint.constant = 0
            messageImageBottomConstraint.isActive = false
            if let urlString = message.attachment {
                loadImage(urlString: urlString)
            }
            self.updateConstraints()
		}
	}
    
    
    func loadImage(urlString: String) {
        if urlString.characters.count == 0 {
            return;
        }
        
        print("urlString:")
        print(urlString)
        //                imageCache.fetch(key: <#T##String#>, formatName: Format(name: "original"), failure: <#T##Fetch.Failer?##Fetch.Failer?##(Error?) -> ()#>, success: <#T##((UIImage) -> ())?##((UIImage) -> ())?##(UIImage) -> ()#>)
        imageCache.fetch(key: urlString).onSuccess { (image) in
            print("was able to set image from cache using key string")
            
            //set your image here
            self.messageImageView.image = image
            
            }.onFailure { (error) in
                "could not fetch image for key \(urlString). error: \(String(describing: error?.localizedDescription))"
                guard let url = URL(string: urlString) else { return }
                print("url:")
                print(url)
                self.messageImageView.hnk_setImageFromURL(url, placeholder: #imageLiteral(resourceName: "default-placeholder-300x300"), format: Format(name: "original"), failure: { (e: Error?) in
                    print("there was an error setting the imageview with the url: \(String(describing: e?.localizedDescription))")
                }, success: { (image: UIImage) in
                    self.messageImageView.image = image
                    print("had to set image from url cause couldn't find it from key")
                })
                
        }
        messageTextLabel.isHidden = true
        messageImageView.isHidden = false
        messageImageHeightConstraint.constant = 200
        messageImageBottomConstraint.isActive = true
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.layer.cornerRadius = 7
        messageImageView.clipsToBounds = true
        
        
        //                guard let url = URL(string: urlString) else { return }
        //                print("urlString: \(urlString)")
        //                print("url: \(url)")
        //                messageImageView.hnk_setImageFromURL(url)
        //                messageImageView.setImageWith(url)
    }
    func setUpUserInfo(userGuid: String){
        self.authorProfileImage.clipsToBounds = true
        self.authorProfileImage.layer.cornerRadius = 7
        self.authorProfileImage.changeToColor(color: .darkGray)
        ChatSpotClient.getUserProfile(userGuid: userGuid, success: { (user: User1) in
            //self.user = user
            if let urlString = user.profileImage {
                self.authorProfileImage.setImageWith(URL(string: urlString)!)
            }
            if user.level > 0 {
                self.authorLevelImage.isHidden = false
            } else {
                self.authorLevelImage.isHidden = true
            }
        }, failure: {
            print("Failure to find user")
        })
    }
    
	
    func handleUsernameTap(){
        self.delegate?.viewUserProfile(userID: self.message.userGuid)
        
    }
    
    func handleCellLongPress(){
        let alertController = UIAlertController(title: self.message.name, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)


        let sendMessage = UIAlertAction(title: "Send Message", style: .default) { action in
            self.delegate?.sendPrivateMessageTo(userID: self.message.userGuid)

        }

        let viewProfile = UIAlertAction(title: "View Profile", style: .default) { action in
            self.delegate?.viewUserProfile(userID: self.message.userGuid)

        }
        alertController.addAction(sendMessage)
        alertController.addAction(viewProfile)
        self.delegate?.presentAlertViewController(alertController: alertController)

    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add tap gesture to authorLabel and authorProfileImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTap))
        authorLabel.addGestureRecognizer(tapGesture)
        authorProfileImage.addGestureRecognizer(tapGesture)
        authorLabel.isUserInteractionEnabled = true
        authorProfileImage.isUserInteractionEnabled = true
        tapGesture.delegate = self
        
        authorLevelImage.transform = CGAffineTransform(rotationAngle: (CGFloat)(-10.0.degreesToRadians))
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleCellLongPress))
        self.addGestureRecognizer(longPressGesture)
        self.isUserInteractionEnabled = true
        longPressGesture.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}
