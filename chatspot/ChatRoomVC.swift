//
//  ChatRoomVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class ChatRoomVC: UIViewController {
	@IBOutlet weak var containerView: UIView!

	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var addPhotoButton: UIButton!
	
	@IBOutlet weak var addEmojiButton: UIButton!
	
	@IBOutlet weak var messageTextField: UITextField!
	
	@IBOutlet weak var sendMessageButton: UIButton!
	
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    
    @IBOutlet weak var chatRoomMemberCountLabel: UILabel!
    
	
	var messages: [Message1] = [Message1]()
    var chatRoom: ChatRoom1!
	var initialY: CGFloat!
    
    var observer: UInt!

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 85
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorStyle = .none

		setUpKeyboardNotifications()
        
        chatRoomNameLabel.text = chatRoom.name
        //chatRoomMemberCountLabel.text = chatRoom.userCount
		
		setUpUI()
        self.startObservingMessages()
    }
    
    private func startObservingMessages() {
        observer = ChatSpotClient.observeNewMessages(roomId: chatRoom.guid, success: { (message: Message1) in
            print(message)
            self.messages.append(message)
            self.tableView.reloadData()
        }, failure: {
            print("error")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        ChatSpotClient.removeObserver(handle: observer)
    }
	
	func setUpUI(){
		addPhotoButton.changeImageViewTo(color: .lightGray)
		addEmojiButton.changeImageViewTo(color: .lightGray)
		messageTextField.autoresizingMask = .flexibleWidth
		
	}
	
	func setUpKeyboardNotifications(){
		initialY = containerView.frame.origin.y
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification: Notification) in
			let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			let keyboardHeight = frame.size.height
			self.containerView.frame.origin.y = self.initialY - keyboardHeight
		}		
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification: Notification) in
			self.containerView.frame.origin.y = self.initialY
		}
	}
	
	
	@IBAction func didTapAwayFromKeyboard(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
    
    @IBAction func onSendMessage(_ sender: UIButton) {
        if !(messageTextField.text?.isEmpty)! {
            let tm = Message1(roomId: chatRoom.guid, message: messageTextField.text!,
                              name: Auth.auth().currentUser!.displayName!)
            
            ChatSpotClient.sendMessage(message: tm, roomId: chatRoom.guid, success: {
                messageTextField.text = ""
                print("message sent!")
            }, failure: {
                print("message sending failed")
            })
        }
    }
}

extension ChatRoomVC: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
    }
    
    @IBAction func didTapAddPhoto(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:nil)
        
        // if it's a photo from the library, not an image from the camera
        //        if let referenceURL = info[UIImagePickerControllerReferenceURL] as? URL {
        
        //        } else {
        //let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }

}


// TableView Methods

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
		//set properties of cell
		cell.message = messages[indexPath.row]
		cell.selectionStyle = UITableViewCellSelectionStyle.none
		//TODO: set cell delegate

		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
}

extension UIImageView {
	func changeToColor(color: UIColor){
		self.image = self.image!.withRenderingMode(.alwaysTemplate)
		self.tintColor = color
	}
}

extension UIButton {
	func changeImageViewTo(color: UIColor){
		let orginalImage = self.imageView?.image
		let newColorImage = orginalImage?.withRenderingMode(.alwaysTemplate)
		self.setImage(newColorImage, for: .normal)
		self.tintColor = color
	}
}
