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
import MBProgressHUD
import ISEmojiView
import GrowingTextView

class ChatRoomVC: UIViewController, ChatMessageCellDelegate {
    static var MAX_MESSAGES_LIMIT: UInt = 10
    
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var addPhotoButton: UIButton!
	@IBOutlet weak var addEmojiButton: UIButton!
	@IBOutlet weak var messageTextView: GrowingTextView!
	@IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var chatRoomMemberCountLabel: UILabel!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var roomImage: UIImageView!
    //Note: Footer will actually be the header once it has been transformed in viewDidLoad()
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewLabel: UILabel!
    
    @IBOutlet weak var containerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    
	var loadingMoreView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var isLoading = false
	var messages: [Message1] = [Message1]()
    var chatRoom: ChatRoom1!
	var initialY: CGFloat!
    var toolbarInitialY: CGFloat!
    var observers = [UInt]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.separatorStyle = .none
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        footerView.transform = tableView.transform
        
        // Set up the keyboard to move appropriately
		setUpKeyboardNotifications()
		
        // UI setup
        setUpUI()
        
        // Infinite scrolling
        //setUpInfiniteScrolling()
        
        self.startObservingMessages()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if chatRoom.guid == nil {
            print("Not attached to a room")
            return
        }

        observers.forEach { ChatSpotClient.removeObserver(handle: $0) }
        observers.removeAll()
    }
    
//MARK: ============ Initial Setup Methods ============
    
    private func onNewMessage(_ message: Message1) {
        print(message)
        self.messages.insert(message, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func startObservingMessages() {
        if chatRoom.guid == nil {
            print("Not attached to a room")
            return
        }

        if chatRoom.isAroundMe {
            self.isLoading = true
            MBProgressHUD.showAdded(to: self.view, animated: true)
            observers.append(ChatSpotClient.observeNewMessagesAroundMe(limit: ChatRoomVC.MAX_MESSAGES_LIMIT, success: { (message: Message1) in
                self.onNewMessage(message)
                self.isLoading = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: {
                print("Error in observeNewMessages")
                self.isLoading = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }))
            
            self.isLoading = true
            MBProgressHUD.showAdded(to: self.view, animated: true)
            observers.append(ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String) in
                let newRoom = ChatSpotClient.chatrooms[roomGuid]
                print("Chat room -> \(roomGuid)")

                self.chatRoom.guid = roomGuid
                self.chatRoom.name = "Around Me - " + newRoom!.name!
                
                self.setRoomName(self.chatRoom.name)
                self.isLoading = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: { (error: Error?) in
                self.isLoading = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }))

        } else {
            self.isLoading = true
            MBProgressHUD.showAdded(to: self.view, animated: true)
            observers.append(ChatSpotClient.observeNewMessages(
                roomId: chatRoom.guid,
                limit: ChatRoomVC.MAX_MESSAGES_LIMIT,
                success: { (message: Message1) in
                    self.onNewMessage(message)
                    self.isLoading = false
                    MBProgressHUD.hide(for: self.view, animated: true)
            }, failure: {
                print("Error in observeNewMessages")
                self.isLoading = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }))
        }
    }

    func setUpInfiniteScrolling(){
        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        loadingMoreView.center = tableFooterView.center
        tableFooterView.insertSubview(loadingMoreView, at: 0)
        self.tableView.tableFooterView = tableFooterView
    }
    
	
    func setRoomName (_ roomName: String) {
        chatRoomNameLabel.attributedText = NSAttributedString(string: roomName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Libertad-Bold", size: 17)!])
        footerViewLabel.text = roomName
        messageTextView.placeHolder = "Message \(roomName)"

    }
    
	func setUpUI(){
        setRoomName(chatRoom.name)

        
        if let urlString = chatRoom.baner {
            if let url = URL(string: urlString) {
                roomImage.setImageWith(url)
            }
        } else {
            roomImage.image = UIImage(named: "people")
        }
        roomImage.clipsToBounds = true
        roomImage.layer.cornerRadius = 7
        
        
        if let memberCount = chatRoom.users?.count {
            let attributes = [NSForegroundColorAttributeName: UIColor.ChatSpotColors.LightestGray, NSFontAttributeName: UIFont(name: "Libertad", size: 15)!]
            
            if memberCount == 0 {
                chatRoomMemberCountLabel.attributedText = NSAttributedString(string: "You're the first one here!", attributes: attributes)
            } else {
                chatRoomMemberCountLabel.attributedText = NSAttributedString(string: "\(memberCount) members", attributes: attributes)
            }
            
        }
        
        addEmojiButton.setImage(addEmojiButton.imageView?.image, for: .selected)
        addPhotoButton.setImage(addPhotoButton.imageView?.image, for: .selected)
		addPhotoButton.changeImageViewTo(color: .lightGray)
		addEmojiButton.changeImageViewTo(color: .lightGray)
        
		messageTextView.autoresizingMask = .flexibleWidth
        messageTextView.maxLength = 300
        messageTextView.trimWhiteSpaceWhenEndEditing = false
        messageTextView.layer.cornerRadius = 7.0
        messageTextView.clipsToBounds = true
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = UIColor.ChatSpotColors.LighterGray.cgColor
        
        toolbarView.layer.borderWidth = 0.3
        toolbarView.layer.borderColor = UIColor.ChatSpotColors.LightGray.cgColor
        sendMessageButton.setAttributedTitle(NSAttributedString(string: "Send", attributes:[NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "Libertad", size: 15)!]), for: .disabled)
        sendMessageButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "Libertad", size: 15)!])
, for: .normal)
        sendMessageButton.isEnabled = false
    }
	
	func setUpKeyboardNotifications(){
        
        initialY = containerTopMarginConstraint.constant
        toolbarInitialY = toolbarBottomConstraint.constant
        
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            
			let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			let keyboardHeight = frame.size.height
            
            if self.needToMoveContainerView(keyboardHeight: keyboardHeight){
                self.containerTopMarginConstraint.constant = self.initialY - keyboardHeight
                self.adjustViewsForKeyboardMove(notification: notification)

            } else {
                self.toolbarBottomConstraint.constant = self.toolbarInitialY + keyboardHeight
                self.adjustViewsForKeyboardMove(notification: notification)
            }
		}
        
		NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification: Notification) in
            
            self.containerTopMarginConstraint.constant = self.initialY
            self.toolbarBottomConstraint.constant = self.toolbarInitialY
            self.adjustViewsForKeyboardMove(notification: notification)
		}
	}
    
    func adjustViewsForKeyboardMove(notification: Notification){
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [UIViewAnimationOptions(rawValue: UInt(curve))], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func needToMoveContainerView(keyboardHeight: CGFloat) -> Bool {
        var indexPath: IndexPath
        if self.messages.count == 0 {
            indexPath = IndexPath(row: 0, section: 0)
        } else {
            indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        }
        let frameForRow = self.tableView.rectForRow(at: indexPath)
        let rectOfRowInSuperview = self.tableView.convert(frameForRow, to: self.tableView.superview)
        if rectOfRowInSuperview.maxY > (self.view.frame.height - keyboardHeight){
            return true
        }
        return false
    }

    
//MARK: ============ User Interaction Methods ============

    
	@IBAction func didTapAwayFromKeyboard(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
    
    
    @IBAction func addEmojiButtonClicked(_ sender: Any) {
        if addEmojiButton.isSelected {
            addEmojiButton.isSelected = false
            messageTextView.inputView = nil
        } else {
            addEmojiButton.isSelected = true
            let emojiView = ISEmojiView()
            emojiView.delegate = self
            messageTextView.inputView = emojiView
            messageTextView.becomeFirstResponder()
        }
        messageTextView.reloadInputViews()
    }
    
    
    @IBAction func addPhotoButtonClicked(_ sender: AnyObject) {
        addPhotoButton.isSelected = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { _ in
            self.openPhotos()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: {_ in
            self.addPhotoButton.isSelected = false
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    
    @IBAction func onSendMessage(_ sender: UIButton) {
        if chatRoom.guid == nil {
            return
        }
        if !(messageTextView.text?.isEmpty)! {
            
            let range = NSRange(location: 0, length: messageTextView.attributedText.length)
            if messageTextView.textStorage.containsAttachments(in: range){
                let attributedString = messageTextView.attributedText
                var location = 0
                var imageUrls = [URL]()
//                var newMessageString = messageTextView.text
//                print("here is original newMessageString:")
//                print(newMessageString)
                while location < range.length {
                    var r = NSRange()
                    if let attributedDictionary = attributedString?.attributes(at: location, effectiveRange: &r) {
                        if let attachment = attributedDictionary[NSAttachmentAttributeName] as? NSTextAttachment {
                            if let image = attachment.image {
                                StorageClient.instance.storeChatImage(userGuid: ChatSpotClient.currentUser.guid!, chatImage: image, success: { (url: URL?) in
                                    if let url = url {
                                        print("There is a url")
                                        imageUrls.append(url)
//                                        newMessageString?.insert(url.absoluteString, at: location)
//                                        newMessageString?.replacingCharacters(in: r, with: url.absoluteString)
//                                        newMessageString?.replaceSubrange(r, with: url.absoluteString)
//                                        newMessageString.replaceCharacters(in: r, with: url.absoluteString)
//                                        print(newMessageString)
                                    }
                                    
                                    
                                }, failure: {
                                    print("Failure trying to store images")
                                })
//                                imageArray.append( attachment!.image!)
                            }
                        }
                        location += r.length
                    }
                }
            }
            print("here is final message text:")
            print(messageTextView.attributedText.string)
            
            let tm = Message1(roomId: chatRoom.guid, message: messageTextView.text!, name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!)
//            let message = Message1(
//            if messageTextView.attributedText.containsAttachments(in: range){
            
//            }
//
            ChatSpotClient.sendMessage(message: tm, room: chatRoom, success: {
                self.messageTextView.text = ""
                self.sendMessageButton.isEnabled = false
                print("message sent!")
                
            }, failure: {
                print("message sending failed")
            })
        }
        
    }
    
//MARK: ============ MessageCellDelegate Methods ============
    
    func presentAlertViewController(alertController: UIAlertController){
        self.present(alertController, animated: true)
    }
    
    func sendPrivateMessageTo(userID: String){
    }
    
    func viewUserProfile(userID: String){
        
    }
}

//MARK: ============ TableView Methods ============

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
		//set properties of cell
		cell.message = messages[indexPath.row]
		cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self

		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
}

//MARK: ============ TextView Delegate Methods ============
extension ChatRoomVC: GrowingTextViewDelegate {
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: GrowingTextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.sendMessageButton.isEnabled = false
        } else {
            
            self.sendMessageButton.isEnabled = true
        }
    }
}

//MARK: ============ ImagePicker Methods ============

extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera(){
        let picker = UIImagePickerController()
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "No camera found.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotos() {
        let picker = UIImagePickerController()
//        self.messageTextView.inputView = picker.view
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        messageTextView.becomeFirstResponder()
//        messageTextView.reloadInputViews()
        present(picker, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        } else {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            image = originalImage
        }

        picker.dismiss(animated: true, completion: { () in
            self.addImageToTextView(image)
            self.addPhotoButton.isSelected = false
        })
    }
    
    func addImageToTextView(_ image: UIImage){
        let textAttachment = NSTextAttachment()
        let oldWidth = image.size.width
        let scaleFactor = oldWidth / (self.messageTextView.frame.size.width - 10)
        textAttachment.image = UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up).roundedCorners
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//        self.messageTextView.textStorage.insert(attrStringWithImage, at: self.messageTextView.selectedRange.location)
        self.messageTextView.textStorage.append(attrStringWithImage)
        self.messageTextView.becomeFirstResponder()
        self.sendMessageButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {() in self.addPhotoButton.isSelected = false })
    }
    
}
//MARK: ============ ScrollView Delegate Methods ============

extension ChatRoomVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!self.isLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                //loadMoreMessages()
            }
        }
    }
    
    // TODO - fix me
    private func loadMoreMessages(){
        if chatRoom.guid == nil{
            print("Not attached to a room")
            return
        }
        
        if chatRoom.isAroundMe {
            self.isLoading = true;
            self.loadingMoreView.startAnimating()
            ChatSpotClient.getMessagesAroundMe(limit: UInt(ChatRoomVC.MAX_MESSAGES_LIMIT), lastMsgId: (messages.last?.guid)!, success: { (messages: [Message1]) in
                //var newMsgs: [Message1] = messages
                //newMsgs += self.messages
                self.messages = messages
                self.tableView.reloadData()
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }, failure: { (e: Error?) in
                print("Failure to load old messages: \(String(describing: e?.localizedDescription))")
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            })
            return
        } else {
            self.isLoading = true;
            self.loadingMoreView.startAnimating()
            ChatSpotClient.getMessagesForRoom(roomId: chatRoom.guid,
                                              limit: UInt(ChatRoomVC.MAX_MESSAGES_LIMIT),
                                              lastMsgId: (messages.last?.guid)!,
                                              success: { (messages: [Message1]) in
                //var newMsgs: [Message1] = messages
                //newMsgs += self.messages
                self.messages = messages
                self.tableView.reloadData()
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }) { (e: Error?) in
                print("Failure to load old messages: \(String(describing: e?.localizedDescription))")
                self.isLoading = false;
                self.loadingMoreView.stopAnimating()
            }
        }
    }
}
 

//MARK: ============ Emoji Delegate Methods ============

extension ChatRoomVC: ISEmojiViewDelegate {
    
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        messageTextView.insertText(emoji)
    }
    
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        messageTextView.deleteBackward()
    }
    
}


//MARK: ============ Object Extensions ============

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

extension UIImage {
    var roundedCorners: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 7.0
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
