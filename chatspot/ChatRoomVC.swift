//
//  ChatRoomVC.swift
//  chatspot
//
//  Created by Eden on 10/10/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ChatRoomVC: UIViewController {
	@IBOutlet weak var containerView: UIView!

	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var addPhotoButton: UIButton!
	
	@IBOutlet weak var addEmojiButton: UIButton!
	
	@IBOutlet weak var messageTextField: UITextField!
	
	@IBOutlet weak var sendMessageButton: UIButton!
	
	
	var messages: [Message] = [Message]()
	var initialY: CGFloat!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 120
		tableView.rowHeight = UITableViewAutomaticDimension
		initialY = containerView.frame.origin.y
		
		setUpKeyboardNotifications()
		
		setUpUI()
		
		
		// Function to populate array of chatroom messages
		//		ChatSpotClient.sharedInstance.someFunctionToGetChatRoomMessages(someParam: Stringorsomething, success: { (messages: [Message]) in
		//			self.messages = chats
		//			self.tableView.reloadData()
		//			KRProgressHUD.showSuccess()
		//		}, failure: { (error: Error) in
		//			print("Could not find chats: \(error.localizedDescription)")
		//		})
		
		
    }
	
	func setUpUI(){

		addPhotoButton.changeImageViewTo(color: .lightGray)
		addEmojiButton.changeImageViewTo(color: .lightGray)
		messageTextField.autoresizingMask = .flexibleWidth
		
	}
	
	func setUpKeyboardNotifications(){
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
