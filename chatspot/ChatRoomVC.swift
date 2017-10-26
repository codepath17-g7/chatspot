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
import ImagePickerSheetController
import Photos

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chatroomDetailSegue") {
            let destinationVC = segue.destination as! ChatRoomDetailVC
            destinationVC.chatroom = self.chatRoom
        }
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
        self.isLoading = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.global(qos: .userInitiated).async {
            if self.chatRoom.isAroundMe {
    //            self.isLoading = true
    //            MBProgressHUD.showAdded(to: self.view, animated: true)
                self.observers.append(ChatSpotClient.observeNewMessagesAroundMe(limit: ChatRoomVC.MAX_MESSAGES_LIMIT, success: { (message: Message1) in
                    DispatchQueue.main.async {
                        self.onNewMessage(message)
                        self.isLoading = false
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }, failure: {
                    DispatchQueue.main.async {
                        print("Error in observeNewMessages")
                        self.isLoading = false
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }))
                
    //            self.isLoading = true
    //            MBProgressHUD.showAdded(to: self.view, animated: true)
                self.observers.append(ChatSpotClient.observeMyAroundMeRoomGuid(success: { (roomGuid: String) in

                    
                    print("Chat room -> \(roomGuid)")
                    self.chatRoom.guid = roomGuid
                    self.chatRoom.name = "Around Me"
                    DispatchQueue.main.async {
                        self.setRoomName(self.chatRoom.name)
                        self.isLoading = false
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }, failure: { (error: Error?) in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }))

            } else {
    //            self.isLoading = true
    //            MBProgressHUD.showAdded(to: self.view, animated: true)
                self.observers.append(ChatSpotClient.observeNewMessages(
                    roomId: self.chatRoom.guid,
                    limit: ChatRoomVC.MAX_MESSAGES_LIMIT,
                    success: { (message: Message1) in
                        DispatchQueue.main.async {
                            self.onNewMessage(message)
                            self.isLoading = false
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                }, failure: {
                    DispatchQueue.main.async {
                        print("Error in observeNewMessages")
                        self.isLoading = false
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }))
            }
        }
    }

//    func setUpInfiniteScrolling(){
//        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
//        loadingMoreView.center = tableFooterView.center
//        tableFooterView.insertSubview(loadingMoreView, at: 0)
//        self.tableView.tableFooterView = tableFooterView
//    }
    
	
    func setRoomName (_ roomName: String) {
        chatRoomNameLabel.attributedText = NSAttributedString(string: roomName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Libertad-Bold", size: 17)!])
        messageTextView.placeHolder = "Message \(roomName)"

    }
    
	func setUpUI(){
        setRoomName(chatRoom.name)
        
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
        
        // create and add an info button in the navigation bar that links to chatroom details
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(openChatroomDetailScreen), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
        
        
        
        // TODO: Fix hardcoded stuff:
        DispatchQueue.global(qos: .utility).async {
            
            // TODO: change to default image
            var roomBanner = #imageLiteral(resourceName: "goldengate")
            if let urlString = self.chatRoom.banner {
                if let url = URL(string: urlString) {
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            roomBanner = image
                        }
                    }
                }
            }
            let footerView = ParallaxView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100), image: roomBanner)
            DispatchQueue.main.async { // 2
                self.tableView.tableFooterView = footerView
                self.tableView.tableFooterView!.transform = self.tableView.transform
            }
        }
    }
    
    @objc private func openChatroomDetailScreen() {
        performSegue(withIdentifier: "chatroomDetailSegue", sender: self)
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
        openImagePickerActionSheet()
    }
    
    
    @IBAction func sendMessageButtonClicked(_ sender: UIButton) {
        if chatRoom.guid == nil {
            return
        }
        if !(messageTextView.text?.isEmpty)! {
            
            let tm = Message1(roomId: chatRoom.guid, message: messageTextView.text!, name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!)

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
        
        let message = messages[indexPath.row]
        if message.system {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialAroundMeCell") as! SpecialAroundMeCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.locationChangeLabel.text = message.message!
            return cell
        }
        
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell") as! ChatMessageCell
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
		//set properties of cell
		cell.message = message
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

extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerSheetControllerDelegate {
    
    func openImagePickerActionSheet() {
        
        // Backup plan of going to camera or camera roll if desired image not shown in action sheet
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.allowsEditing = true
            var sourceType = source
            if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
                sourceType = .photoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            // Present camera or full photo gallery
            self.present(controller, animated: true, completion: nil)
        }
        
        
        // Action sheet controller setup:
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.delegate = self

        // Add "Take Photo or Video" and "Add caption" buttons
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add caption", comment: "Action Title"), handler: { _ in
            
            presentImagePickerController(.camera)
            
        }, secondaryHandler: { _, numberOfPhotos in
            
            print("Caption \(numberOfPhotos) photos")
            
        }))
        
        // Add "Photo Library" and "Send photos" buttons
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title") as NSString, $0) as String}, handler: { _ in
            
            presentImagePickerController(.photoLibrary)
            
        }, secondaryHandler: { _, numberOfPhotos in
            
            self.sendAssets(selectedAssets: controller.selectedAssets)
            
        }))

        // Add "Cancel" button
        controller.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title"), handler: { _ in
            
            self.addPhotoButton.isSelected = false

        }))
        
        // Presentation for different devices
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        // Present ImagePickerActionSheet
        present(controller, animated: true, completion: nil)
    }
    
    
    
    // Send the pictures, videos, etc.
    func sendAssets(selectedAssets: [PHAsset]){
        
        //for every asset in the asset array
        for asset in selectedAssets {
            
            //retrieve small image for that asset
            if asset.mediaType == .image {
                getSmallImage(asset: asset, completion: {(image: UIImage?) -> Void in
                    if let img = image {
                        self.storeAndSendImage(image: img, asset: asset)
                    }
                })
//            //retrieve full size image for that asset
//            if let image = getFullImage(asset: asset){
//
//            }
            } else if asset.mediaType == .video {
                //    //retrieve video
                //    if let video = getVideoForAsset(asset: asset){
                //
                //    }
            }
        }
    }
    
    func storeAndSendImage(image: UIImage, asset: PHAsset?){
        //store asset in firebase by calling storeChatImage on UIImage
        StorageClient.instance.storeChatImage(userGuid: ChatSpotClient.currentUser.guid!, chatImage: image, success: { (url: URL?) in
            if let url = url {
                //send message with string of imageURL in it
                let attachment = url.absoluteString
                
                let tm = Message1(roomId: self.chatRoom.guid, message: "", name: ChatSpotClient.currentUser.name!, userGuid: ChatSpotClient.currentUser.guid!, attachment: attachment)
                
                
                ChatSpotClient.sendMessage(message: tm, room: self.chatRoom, success: {
                    print("photo sent!")
                    
                }, failure: {
                    print("photo sending failed")
                })
                if let asset = asset {
                    DispatchQueue.global(qos: .utility).async {
                        self.getFullImage(asset: asset, completion: {(image: UIImage?) -> Void in
                            if let img = image {
                                self.storeFullSizeMedia(media: img, message: tm)
                            }
                        })
                    }
                }
                self.addPhotoButton.isSelected = false
                
            }
        }, failure: {
            print("Failure trying to store images")
        })

    }
    
    func storeFullSizeMedia(media: Any, message: Message1){
        DispatchQueue.global(qos: .utility).async {
//            if let image = media as? UIImage {
//                StorageClient.instance.storeChatImage(userGuid: ChatSpotClient.currentUser.guid!, chatImage: image, success: { (url: URL?) in
//                    if let url = url {
//                        let attachment = url.absoluteString
//                        message.
//                    }
//                })
//            }
//            if let video = media as? //video file {
//            }
        
        }
    }
    
    func getSmallImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options, resultHandler: { (result: UIImage?, _) -> Void in
            if let image = result {
                completion(image)
            } else {
                completion(nil)
            }
        })
    }
    
    // FOR LATER USE:
    func getFullImage(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        //retrieve real image for that asset
        manager.requestImageData(for: asset, options: options) { (data: Data?, _, _, _) in
            if let imageData = data {
                completion(UIImage(data: imageData))
            } else {
                completion(nil)
            }
        }
    }
    
    // FOR LATER USE:
    func getVideoForAsset(asset: PHAsset) -> AVPlayerItem? {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
//        options.progressHandler
        options.deliveryMode = .fastFormat
        options.version = .current
        var video: AVPlayerItem?

        manager.requestPlayerItem(forVideo: asset, options: options) { (playerItem: AVPlayerItem?, _) in
            if let vid = playerItem {
                video = vid
            }
        }
        return video
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
            self.storeAndSendImage(image: image, asset: nil)
        })
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
