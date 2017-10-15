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
	
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    
    @IBOutlet weak var chatRoomMemberCountLabel: UILabel!
    
	
	var messages: [Message] = [Message]()
    var chatRoom: ChatRoom1!
	var initialY: CGFloat!
	
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
		
		
		// Function to populate array of chatroom messages
		//		ChatSpotClient.sharedInstance.someFunctionToGetChatRoomMessages(someParam: Stringorsomething, success: { (messages: [Message]) in
		//			self.messages = messages
		//			self.tableView.reloadData()
		//			KRProgressHUD.showSuccess()
		//		}, failure: { (error: Error) in
		//			print("Could not find chats: \(error.localizedDescription)")
		//		})

        setupMockData()
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
    
	
    
    func setupMockData(){
        let chatroom = ChatRoom(guid: "6", createdAt: 11.11, name: "Rengstorff Park")
        let user1 = User(guid: "1111", createdAt: 13.00, name: "Eden")
        let user2 = User(guid: "2222", createdAt: 14.00, name: "Phuong")
        let user3 = User(guid: "3333", createdAt: 15.00, name: "Hakeem")
        let user4 = User(guid: "4444", createdAt: 16.00, name: "Varun")
        let message1 = Message(guid: "11", createdAt: 1507930655, image: nil, message: "Hey everyone, what's up?", user: user1, chatRoom: chatroom)
        let message2 = Message(guid: "12", createdAt: 1507930655, image: nil, message: "Hey guys", user: user2, chatRoom: chatroom)
        let message3 = Message(guid: "13", createdAt: 1507930655, image: nil, message: "Anything to do around here? kjfshdflks it jj jjj jahdflkjs dhflk jasdh fkljsd hfkj sad fhkjs jhgdjfhgsd gfdhgfdhf", user: user3, chatRoom: chatroom)
        let message4 = Message(guid: "14", createdAt: 1507930655, image: nil, message: "Hey everyone, what's up?", user: user4, chatRoom: chatroom)
        let message5 = Message(guid: "15", createdAt: 1507930655, image: nil, message: "Hi", user: user1, chatRoom: chatroom)
        let message6 = Message(guid: "16", createdAt: 1507930655, image: nil, message: "what's up?", user: user2, chatRoom: chatroom)
        let message7 = Message(guid: "17", createdAt: 1507930655, image: nil, message: "Hey hing to do around here? kjfshdflks jahdflkjs dhflk jasdh fkljsd hfkj sad fhkjs jhgdjfhgsd gfd, what's up?", user: user3, chatRoom: chatroom)
        let message8 = Message(guid: "18", createdAt: 1507930655, image: nil, message: "yooooooo", user: user4, chatRoom: chatroom)
        let message9 = Message(guid: "19", createdAt: 1507930655, image: nil, message: "Hey, what's up?", user: user1, chatRoom: chatroom)
        messages = [message1, message2, message3, message4, message5, message6, message7, message8, message9]
        self.tableView.reloadData()
    }
	
	

}

extension ChatRoomVC: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        FirebaseClient.sharedInstance.sendMessage(messageText: textField.text! as String, user: User.currentUser!, success: { (message: Message) in
//            self.delegate?.updateTableViewWithMessage(message: message)
//        }, failure: { (e: Error) in
//            print("Error: \(e.localizedDescription)")
//        })
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
